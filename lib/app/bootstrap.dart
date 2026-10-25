import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/app_locator.dart';
import '../core/platform/process_text_service.dart';
import '../core/router/app_route.dart';
import '../core/router/app_router.dart';
import '../features/auth/auth.dart';
import '../features/quick_capture/quick_capture.dart';
import '../features/reminder/reminder.dart';
import 'app.dart';

/// Provides the shared auth cubit and auth-aware router to the app.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  final AuthCubit _authCubit = locator<AuthCubit>();
  final ProcessTextService _processText = locator<ProcessTextService>();
  final QuickCaptureCoordinator _quickCapture =
      locator<QuickCaptureCoordinator>();

  late final Future<void> _initialProcessText = _processText.loadInitialWord();
  late final StreamSubscription<AuthState> _authSubscription;
  bool? _wasAuthenticated;

  late final _AuthStreamRefresh _refresh = _AuthStreamRefresh(
    _authCubit.stream,
  );

  late final GoRouter _router = AppRouter.create(
    initialLocation: AppRoute.loading.path,
    refreshListenable: _refresh,
    redirect: _redirect,
  );

  @override
  void initState() {
    super.initState();
    _authSubscription = _authCubit.stream.listen(_syncReminders);
    _syncReminders(_authCubit.state);
    _processText.addListener(_openPendingWord);
  }

  void _syncReminders(AuthState auth) {
    if (auth.isInitializing || _wasAuthenticated == auth.isAuthenticated) {
      return;
    }

    _wasAuthenticated = auth.isAuthenticated;
    unawaited(_rescheduleReminders());
    if (auth.isAuthenticated) unawaited(_openPendingWord());
  }

  Future<void> _openPendingWord() async {
    await _initialProcessText;
    if (!mounted || !_authCubit.state.isAuthenticated) return;
    if (!_processText.hasPendingWord) return;

    _router.go(AppRoute.home.path);
  }

  Future<void> _rescheduleReminders() async {
    try {
      await locator<ReminderRepository>().reschedule();
    } on Object {
      // Reminder scheduling must never block app startup.
    }
  }

  String? _redirect(BuildContext context, GoRouterState state) {
    final auth = _authCubit.state;
    final onLoading = state.matchedLocation == AppRoute.loading.path;
    final onSignIn = state.matchedLocation == AppRoute.signIn.path;

    if (auth.isInitializing && !auth.hasError) {
      return onLoading ? null : AppRoute.loading.path;
    }

    if (auth.isInitializing) {
      return onSignIn ? null : AppRoute.signIn.path;
    }

    if (!auth.isAuthenticated) {
      return onSignIn ? null : AppRoute.signIn.path;
    }

    return onSignIn || onLoading ? AppRoute.deck.path : null;
  }

  @override
  void dispose() {
    _processText.removeListener(_openPendingWord);
    _authSubscription.cancel();
    _refresh.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _authCubit,
      child: ListenableBuilder(
        listenable: _quickCapture,
        builder: (context, _) {
          if (_quickCapture.isOverlayVisible) {
            return const QuickCaptureOverlayApp();
          }
          return WordlearnApp(router: _router);
        },
      ),
    );
  }
}

/// Turns a cubit stream into a [Listenable] for `GoRouter.refreshListenable`.
class _AuthStreamRefresh extends ChangeNotifier {
  _AuthStreamRefresh(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
