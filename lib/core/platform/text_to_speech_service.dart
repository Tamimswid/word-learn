import 'package:dartz/dartz.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../errors/failure.dart';

/// Reads English words and sentences aloud with the platform speech engine.
class TextToSpeechService {
  TextToSpeechService({FlutterTts? engine}) : _engine = engine ?? FlutterTts();

  final FlutterTts _engine;
  bool _configured = false;
  String _language = 'en-US';

  Future<Either<Failure, Unit>> speak(
    String text, {
    String language = 'en-US',
  }) async {
    final value = text.trim();
    if (value.isEmpty) {
      return const Left(Failure('Okunacak metin bulunamadı.'));
    }

    try {
      await _configure(language);
      await _engine.stop();
      await _engine.speak(value);
      return const Right(unit);
    } catch (error, stackTrace) {
      return Left(
        Failure(
          'Okunuş çalıştırılamadı.',
          type: FailureType.unexpected,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Either<Failure, Unit>> stop() async {
    try {
      await _engine.stop();
      return const Right(unit);
    } catch (error, stackTrace) {
      return Left(
        Failure(
          'Okunuş durdurulamadı.',
          type: FailureType.unexpected,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _configure(String language) async {
    if (!_configured) {
      await _engine.setSpeechRate(0.45);
      await _engine.setPitch(1);
      await _engine.setVolume(1);
      _configured = true;
    }

    if (_language != language) {
      await _engine.setLanguage(language);
      _language = language;
    }
  }
}
