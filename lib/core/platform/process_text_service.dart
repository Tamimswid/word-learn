import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Receives text shared through Android's Process Text menu.
class ProcessTextService extends ChangeNotifier {
  ProcessTextService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName) {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  static const String _channelName = 'wordlearn/process_text';

  final MethodChannel _channel;
  String? _pendingWord;

  bool get hasPendingWord => _pendingWord != null;

  /// Reads the text that launched the app, if it came from the Process Text menu.
  Future<void> loadInitialWord() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    try {
      _setPending(await _channel.invokeMethod<String>('getInitialText'));
    } on MissingPluginException {
      // Platform channel is not available (for example in widget tests).
    }
  }

  String? takePendingWord() {
    final word = _pendingWord;
    _pendingWord = null;
    return word;
  }

  Future<void> _onMethodCall(MethodCall call) async {
    if (call.method == 'processText') {
      _setPending(call.arguments as String?);
    }
  }

  void _setPending(String? word) {
    final trimmed = word?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    _pendingWord = trimmed;
    notifyListeners();
  }
}
