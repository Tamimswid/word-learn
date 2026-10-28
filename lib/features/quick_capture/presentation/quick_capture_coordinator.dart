import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../data/repositories/quick_capture_repository.dart';
import 'cubit/quick_capture_cubit.dart';

/// Owns the background capture experience: the macOS menu bar item, Dock
/// reopen, global shortcut and floating overlay, plus the Android share dialog.
///
/// The main window is only used for the regular app (sign-in, dashboard). While
/// it is hidden the app keeps running in the Dock and menu bar, and captures the
/// selected text of whichever app is in front.
class QuickCaptureCoordinator extends ChangeNotifier
    with WindowListener, TrayListener {
  QuickCaptureCoordinator(this._repository, this._cubit, this._auth);

  static const String _trayIcon = 'assets/icons/tray_word.png';
  static const String _captureKey = 'capture';
  static const String _panelKey = 'panel';
  static const String _quitKey = 'quit';

  static const Size _panelSize = Size(1180, 780);
  static const Size _overlaySize = Size(300, 104);
  static const double _overlayMargin = 16;

  static const Duration _successDelay = Duration(seconds: 2);
  static const Duration _failureDelay = Duration(seconds: 3);

  static const MethodChannel _overlayChannel = MethodChannel(
    'wordlearn/overlay',
  );
  static const MethodChannel _lifecycleChannel = MethodChannel(
    'wordlearn/lifecycle',
  );
  static const MethodChannel _captureChannel = MethodChannel(
    'wordlearn/quick_capture',
  );

  final QuickCaptureRepository _repository;
  final QuickCaptureCubit _cubit;
  final AuthCubit _auth;

  final HotKey _hotKey = HotKey(
    identifier: 'wordlearn-capture',
    key: PhysicalKeyboardKey.keyK,
    modifiers: [HotKeyModifier.meta, HotKeyModifier.shift],
    scope: HotKeyScope.system,
  );

  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isOverlayVisible = false;

  bool get isOverlayVisible => _isOverlayVisible;

  Future<void> initialize() async {
    if (_isInitialized || !Platform.isMacOS) return;
    _isInitialized = true;

    await windowManager.ensureInitialized();
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);

    trayManager.addListener(this);
    _lifecycleChannel.setMethodCallHandler(_handleLifecycleCall);
    await _setUpTray();
    await _setUpHotKey();
    await _setUpLaunchAtStartup();

    await windowManager.setSize(_panelSize);
    await windowManager.center();
  }

  /// Shows the regular app window. Used by the tray icon, the Dock reopen event
  /// and whenever a capture is requested without an authenticated session.
  Future<void> showPanel() async {
    if (!Platform.isMacOS) return;

    await _overlayChannel.invokeMethod<void>('hide');
    _setOverlayVisible(false);
    await _overlayChannel.invokeMethod<void>('exit');
    await windowManager.setResizable(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setSize(_panelSize);
    await windowManager.center();
    await windowManager.setOpacity(1);
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _handleLifecycleCall(MethodCall call) async {
    if (call.method == 'openPanel') await showPanel();
  }

  /// Runs the Android share/process-text capture and closes the dialog activity
  /// once the result has been readable for a moment.
  Future<void> runSharedCapture() async {
    if (!Platform.isAndroid || _isCapturing) return;

    _isCapturing = true;
    try {
      final text = await _takeSharedText();
      if (text == null) {
        await _closeSharedCapture();
        return;
      }

      if (!(await _awaitAuth()).isAuthenticated) {
        await _captureChannel.invokeMethod<void>('openApp');
        return;
      }

      _cubit.reset();
      await _cubit.save(text);
      await Future<void>.delayed(
        _cubit.state.isSuccess ? _successDelay : _failureDelay,
      );
      await _closeSharedCapture();
    } on Object {
      await _closeSharedCapture();
    } finally {
      _isCapturing = false;
    }
  }

  Future<String?> _takeSharedText() async {
    try {
      final text = await _captureChannel.invokeMethod<String>('takeText');
      final trimmed = text?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    } on PlatformException {
      return null;
    }
  }

  Future<void> _closeSharedCapture() async {
    try {
      await _captureChannel.invokeMethod<void>('close');
    } on PlatformException {
      // The activity is already gone.
    }
  }

  /// A capture can start before Supabase has restored the stored session.
  Future<AuthState> _awaitAuth() async {
    if (!_auth.state.isInitializing) return _auth.state;

    try {
      return await _auth.stream
          .firstWhere((state) => !state.isInitializing)
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      return _auth.state;
    }
  }

  Future<void> _setUpTray() async {
    await trayManager.setIcon(_trayIcon, isTemplate: true, iconSize: 18);
    await trayManager.setToolTip('Kelime');
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: _captureKey, label: 'Kelime Yakala  (⌘⇧K)'),
          MenuItem(key: _panelKey, label: 'Paneli Aç'),
          MenuItem.separator(),
          MenuItem(key: _quitKey, label: 'Çıkış'),
        ],
      ),
    );
  }

  Future<void> _setUpHotKey() async {
    await hotKeyManager.unregisterAll();
    await hotKeyManager.register(
      _hotKey,
      keyDownHandler: (_) => unawaited(_captureSelection()),
    );
  }

  Future<void> _setUpLaunchAtStartup() async {
    try {
      launchAtStartup.setup(
        appName: 'Kelime',
        appPath: Platform.resolvedExecutable,
      );
      if (!await launchAtStartup.isEnabled()) {
        await launchAtStartup.enable();
      }
    } on Object {
      // Login items require a signed app in a stable location (for example
      // /Applications); local builds are allowed to skip this.
    }
  }

  Future<void> _captureSelection() async {
    if (_isCapturing) return;

    if (!_auth.state.isAuthenticated) {
      await showPanel();
      return;
    }

    _isCapturing = true;
    try {
      _cubit.reset();
      // The overlay reuses the main window, so a visible panel is put away
      // before the window shrinks into the floating capture card.
      if (await windowManager.isVisible()) await windowManager.hide();
      await _showOverlay();

      final selection = await _repository.readSelection();
      await selection.fold<Future<void>>(
        (failure) async {
          _cubit.fail(failure.message);
          await _closeOverlay(_failureDelay);
        },
        (text) async {
          await _cubit.save(text);
          await _closeOverlay(
            _cubit.state.isSuccess ? _successDelay : _failureDelay,
          );
        },
      );
    } finally {
      _isCapturing = false;
    }
  }

  /// Keeps the result readable for a moment, then hides the overlay. The app
  /// keeps running in the menu bar and Dock.
  Future<void> _closeOverlay(Duration delay) async {
    await Future<void>.delayed(delay);
    await _hideOverlay();
    _cubit.reset();
  }

  Future<void> _showOverlay() async {
    await windowManager.setResizable(false);
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setSize(_overlaySize);
    await windowManager.setPosition(await _overlayPosition());
    await _overlayChannel.invokeMethod<void>('enter');

    _setOverlayVisible(true);
    // Give Flutter a frame to swap the root widget before the window appears.
    await Future<void>.delayed(const Duration(milliseconds: 32));
    await _overlayChannel.invokeMethod<void>('show');
  }

  Future<void> _hideOverlay() async {
    if (!_isOverlayVisible) return;

    await _overlayChannel.invokeMethod<void>('hide');
    _setOverlayVisible(false);
    await _overlayChannel.invokeMethod<void>('exit');
    await windowManager.setResizable(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setSize(_panelSize);
    await windowManager.center();
  }

  Future<Offset> _overlayPosition() async {
    final cursor = await screenRetriever.getCursorScreenPoint();
    final display = await screenRetriever.getPrimaryDisplay();
    final origin = display.visiblePosition ?? Offset.zero;
    final size = display.visibleSize ?? display.size;
    final bounds = origin & size;

    final margin = const Offset(_overlayMargin, _overlayMargin);
    if (!bounds.contains(cursor)) return cursor + margin;

    var position = cursor + margin;
    if (position.dx + _overlaySize.width > bounds.right) {
      position = Offset(
        cursor.dx - _overlaySize.width - _overlayMargin,
        position.dy,
      );
    }
    if (position.dy + _overlaySize.height > bounds.bottom) {
      position = Offset(
        position.dx,
        cursor.dy - _overlaySize.height - _overlayMargin,
      );
    }

    return Offset(
      position.dx
          .clamp(bounds.left, bounds.right - _overlaySize.width)
          .toDouble(),
      position.dy
          .clamp(bounds.top, bounds.bottom - _overlaySize.height)
          .toDouble(),
    );
  }

  Future<void> _quit() async {
    try {
      await hotKeyManager.unregisterAll();
      trayManager.removeListener(this);
      await trayManager.destroy();
    } on Object {
      // Quit even when a plugin cannot clean up.
    }
    exit(0);
  }

  void _setOverlayVisible(bool visible) {
    if (_isOverlayVisible == visible) return;
    _isOverlayVisible = visible;
    notifyListeners();
  }

  @override
  void onTrayIconMouseDown() {
    unawaited(showPanel());
  }

  @override
  void onTrayIconRightMouseDown() {
    unawaited(trayManager.popUpContextMenu());
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case _captureKey:
        unawaited(_captureSelection());
      case _panelKey:
        unawaited(showPanel());
      case _quitKey:
        unawaited(_quit());
    }
  }

  @override
  void onWindowClose() {
    unawaited(windowManager.hide());
  }
}
