import 'package:dartz/dartz.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../errors/failure.dart';

/// Tunable values for one dictation session, kept out of the widgets.
class SpeechToTextConfig {
  const SpeechToTextConfig({
    this.localePreferences = const <String>['en_US', 'en_GB'],
    this.listenFor = const Duration(seconds: 60),
    this.sendAfterPause = const Duration(milliseconds: 1500),
    this.micOpenDelay = const Duration(milliseconds: 300),
    this.soundLevelThreshold = 0.05,
    this.onDevice = false,
  });

  /// Tutor conversation: a long window, and the learner's turn is sent once
  /// they stay silent for [sendAfterPause].
  static const SpeechToTextConfig conversation = SpeechToTextConfig();

  final List<String> localePreferences;
  final Duration listenFor;

  /// Silence length that ends the learner's turn and sends the heard words.
  final Duration sendAfterPause;

  /// Gap after the teacher stops talking before the mic opens, so the tail
  /// of the TTS voice is never recorded.
  final Duration micOpenDelay;

  /// Sound level (0–1) above which the learner counts as speaking.
  final double soundLevelThreshold;

  final bool onDevice;
}

typedef SpeechHeard = void Function(String words);
typedef SpeechListeningChanged = void Function(bool listening);
typedef SpeechFailure = void Function(Failure failure);
typedef SpeechSoundLevel = void Function(double level);

/// Turns spoken English into text with the platform speech recognizer.
///
/// One session at a time: [start] replaces callbacks, [stop] keeps the words
/// already heard, [cancel] discards the session.
class SpeechToTextService {
  SpeechToTextService({SpeechToText? engine})
    : _engine = engine ?? SpeechToText();

  final SpeechToText _engine;

  bool _initialized = false;
  bool _available = false;
  bool _listening = false;
  String? _localeId;

  SpeechHeard? _onPartial;
  SpeechHeard? _onFinal;
  SpeechListeningChanged? _onListeningChanged;
  SpeechFailure? _onFailure;

  bool get isListening => _listening;

  bool get isAvailable => _available;

  Future<Either<Failure, Unit>> initialize({
    SpeechToTextConfig config = SpeechToTextConfig.conversation,
  }) async {
    if (_initialized) return const Right(unit);

    try {
      final available = await _engine.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
      );

      if (!available) {
        // Keep the attempt repeatable so a granted permission can be picked up.
        return const Left(
          Failure(
            'التعرف على الصوت غير متاح على هذا الجهاز.',
            type: FailureType.permission,
          ),
        );
      }

      _available = true;
      _initialized = true;
      _localeId = await _resolveLocale(config);
      return const Right(unit);
    } catch (error, stackTrace) {
      _available = false;
      _initialized = false;
      return Left(
        Failure('تعذر تشغيل الميكروفون.', cause: error, stackTrace: stackTrace),
      );
    }
  }

  Future<Either<Failure, Unit>> start({
    required SpeechHeard onPartial,
    required SpeechHeard onFinal,
    SpeechToTextConfig config = SpeechToTextConfig.conversation,
    SpeechListeningChanged? onListeningChanged,
    SpeechFailure? onFailure,
    SpeechSoundLevel? onSoundLevel,
  }) async {
    final ready = await initialize(config: config);
    if (ready.isLeft()) return ready;

    if (_listening) {
      await stop();
    }

    _onPartial = onPartial;
    _onFinal = onFinal;
    _onListeningChanged = onListeningChanged;
    _onFailure = onFailure;

    try {
      await _engine.listen(
        onResult: _handleResult,
        onSoundLevelChange: onSoundLevel,
        listenOptions: SpeechListenOptions(
          localeId: _localeId,
          listenFor: config.listenFor,
          onDevice: config.onDevice,
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
      );
      _setListening(true);
      return const Right(unit);
    } catch (error, stackTrace) {
      return Left(
        Failure('تعذر تشغيل الميكروفون.', cause: error, stackTrace: stackTrace),
      );
    }
  }

  /// Ends the session and lets the platform deliver the final words.
  Future<Either<Failure, Unit>> stop() async {
    try {
      await _engine.stop();
      _setListening(false);
      return const Right(unit);
    } catch (error, stackTrace) {
      return Left(
        Failure('تعذر إيقاف الاستماع.', cause: error, stackTrace: stackTrace),
      );
    }
  }

  /// Ends the session without keeping the words.
  Future<void> cancel() async {
    _onPartial = null;
    _onFinal = null;
    _onListeningChanged = null;
    _onFailure = null;

    try {
      await _engine.cancel();
    } catch (_) {
      // Nothing to recover from; the microphone is simply released.
    }
    _setListening(false);
  }

  Future<String?> _resolveLocale(SpeechToTextConfig config) async {
    try {
      final locales = await _engine.locales();
      for (final preferred in config.localePreferences) {
        for (final locale in locales) {
          if (locale.localeId == preferred) return preferred;
        }
      }
      for (final locale in locales) {
        if (locale.localeId.toLowerCase().startsWith('en')) {
          return locale.localeId;
        }
      }
    } catch (_) {
      // Fall back to the device default locale.
    }
    return null;
  }

  void _handleResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();

    if (!result.finalResult) {
      if (words.isNotEmpty) _onPartial?.call(words);
      return;
    }

    _setListening(false);

    if (words.isEmpty) {
      _onFailure?.call(const Failure('لم أسمعك. حاول مرة أخرى.'));
      return;
    }

    _onFinal?.call(words);
  }

  void _handleStatus(String status) {
    switch (status) {
      case 'listening':
        _setListening(true);
      case 'notListening':
      case 'done':
        _setListening(false);
    }
  }

  void _handleError(SpeechRecognitionError error) {
    _setListening(false);
    _onFailure?.call(_failureFor(error.errorMsg));
  }

  void _setListening(bool value) {
    if (_listening == value) return;
    _listening = value;
    _onListeningChanged?.call(value);
  }

  static Failure _failureFor(String errorMsg) {
    return switch (errorMsg) {
      'error_permission' => const Failure(
        'لم يُمنح إذن الميكروفون.',
        type: FailureType.permission,
        code: 'error_permission',
      ),
      'error_no_match' || 'error_speech_timeout' => const Failure(
        'لم أسمعك. حاول مرة أخرى.',
        code: 'error_no_match',
      ),
      'error_language_not_supported' ||
      'error_language_unavailable' => const Failure(
        'التعرف على الإنجليزية غير مدعوم على هذا الجهاز.',
        code: 'error_language_not_supported',
      ),
      'error_network' || 'error_network_timeout' => const Failure(
        'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
        type: FailureType.network,
        code: 'error_network',
      ),
      _ => const Failure('تعذر التعرف على الصوت. حاول مرة أخرى.'),
    };
  }
}
