import 'dart:async';
import 'dart:io' show File;

import 'package:audioplayers/audioplayers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:path_provider/path_provider.dart';

import '../errors/failure.dart';

/// Tunable voice settings for the Edge TTS engine, kept out of the widgets.
class TextToSpeechConfig {
  const TextToSpeechConfig({
    this.voice = 'en-US-AriaNeural',
    this.rate = '-15%',
    this.pitch = '+0Hz',
  });

  static const TextToSpeechConfig standard = TextToSpeechConfig();

  final String voice;
  final String rate;
  final String pitch;
}

/// Reads English words and sentences aloud with the Microsoft Edge
/// online speech engine.
class TextToSpeechService {
  TextToSpeechService({FlutterEdgeTts? engine, AudioPlayer? player})
    : _engine =
          engine ?? FlutterEdgeTts(voice: TextToSpeechConfig.standard.voice),
      _player = player ?? AudioPlayer();

  final FlutterEdgeTts _engine;
  final AudioPlayer _player;

  String? _filePath;
  StreamSubscription<void>? _completionSubscription;

  /// Speaks [text] and resolves only when the playback has finished, so
  /// callers know the teacher has actually stopped talking.
  ///
  /// [onStarted] fires once the audio is actually audible, together with its
  /// duration, so callers can sync visuals (typing) to the real pace.
  Future<Either<Failure, Unit>> speak(
    String text, {
    String language = 'en-US',
    void Function(Duration audioDuration)? onStarted,
  }) async {
    final value = text.trim();
    if (value.isEmpty) {
      return const Left(Failure('لم يتم العثور على نص لقراءته.'));
    }

    try {
      await _interrupt();

      final result = await _engine.synthesize(
        value,
        prosody: EdgeTtsProsody(
          rate: TextToSpeechConfig.standard.rate,
          pitch: TextToSpeechConfig.standard.pitch,
        ),
      );

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/tutor_tts.mp3');
      await file.writeAsBytes(result.audioBytes, flush: true);
      _filePath = file.path;

      final completion = Completer<void>();
      _completionSubscription = _player.onPlayerComplete.listen(
        (_) {
          if (!completion.isCompleted) completion.complete();
        },
        onError: (Object error) {
          if (!completion.isCompleted) completion.completeError(error);
        },
      );

      // play() resolves when playback starts; the completer above waits
      // for the real end.
      await _play(file, onStarted);
      await completion.future.timeout(const Duration(minutes: 2));

      await _completionSubscription?.cancel();
      _completionSubscription = null;
      await _deleteFile();

      return const Right(unit);
    } catch (error, stackTrace) {
      await _completionSubscription?.cancel();
      _completionSubscription = null;
      await _deleteFile();
      return Left(
        Failure(
          'تعذر تشغيل النطق.',
          type: FailureType.unexpected,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Starts playback and reports the real audio length once known, so the
  /// typing animation can span exactly the speech duration.
  Future<Duration> _play(
    File file,
    void Function(Duration audioDuration)? onStarted,
  ) async {
    final firstDuration = Completer<Duration>();
    final durationSubscription = _player.onDurationChanged.listen((duration) {
      if (!firstDuration.isCompleted && duration.inMilliseconds > 0) {
        firstDuration.complete(duration);
      }
    });

    try {
      await _player.play(DeviceFileSource(file.path));

      var audioDuration = Duration.zero;
      try {
        audioDuration = await firstDuration.future.timeout(
          const Duration(seconds: 2),
        );
      } on TimeoutException {
        // Some platforms never report a duration; fall back to zero.
      }

      onStarted?.call(audioDuration);
      return audioDuration;
    } finally {
      await durationSubscription.cancel();
    }
  }

  Future<Either<Failure, Unit>> stop() async {
    try {
      await _interrupt();
      await _deleteFile();
      return const Right(unit);
    } catch (error, stackTrace) {
      return Left(
        Failure(
          'تعذر إيقاف النطق.',
          type: FailureType.unexpected,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _interrupt() async {
    await _completionSubscription?.cancel();
    _completionSubscription = null;
    await _player.stop();
  }

  Future<void> _deleteFile() async {
    final path = _filePath;
    _filePath = null;
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Silme hatası oynatmayı etkilemez.
    }
  }
}
