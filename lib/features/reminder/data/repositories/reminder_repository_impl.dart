import 'dart:math';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../deck_session/deck_session.dart';
import '../data_sources/notification_data_source.dart';
import '../data_sources/reminder_settings_data_source.dart';
import '../models/reminder_cadence.dart';
import '../models/reminder_settings.dart';
import '../models/reminder_slot.dart';
import 'reminder_repository.dart';

/// Builds the notifications for today: one per deck word plus periodic nudges
/// that ask the user to come back.
///
/// Word slots stay between [_minGapMinutes] and [_maxGapMinutes] apart. Prompts
/// step by [ReminderCadence.intervalFor] measured from the moment the app was
/// opened and never leave the user's learning window.
class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(
    this._deck,
    this._settings,
    this._notifications, {
    ReminderCadence cadence = ReminderCadence.standard,
    Random? random,
    DateTime Function()? now,
  }) : _cadence = cadence,
       _random = random ?? Random(),
       _now = now ?? DateTime.now;

  static const int _minGapMinutes = 10;
  static const int _maxGapMinutes = 120;
  static const int _maxScheduled = 50;
  static const int _wordIdBase = 9100;
  static const int _promptIdBase = 9200;

  static const String _promptTitle = 'Kelime tekrarı';

  final DeckRepository _deck;
  final ReminderSettingsDataSource _settings;
  final NotificationDataSource _notifications;
  final ReminderCadence _cadence;
  final Random _random;
  final DateTime Function() _now;

  @override
  Future<ReminderSettings> loadSettings() => _settings.load();

  @override
  Future<Either<Failure, ReminderSettings>> saveSettings(
    ReminderSettings settings,
  ) async {
    if (!settings.isValid) {
      return const Left(Failure('Bitiş saati başlangıçtan sonra olmalı.'));
    }

    if (settings.isEnabled) {
      bool granted;
      try {
        granted = await _notifications.requestPermissions();
      } on Object catch (error, stackTrace) {
        return Left(
          Failure(
            'Bildirim izni kontrol edilemedi.',
            type: FailureType.permission,
            cause: error,
            stackTrace: stackTrace,
          ),
        );
      }

      if (!granted) {
        return const Left(
          Failure(
            'Bildirim izni verilmedi. Ayarlardan izin verip tekrar dene.',
            type: FailureType.permission,
          ),
        );
      }
    }

    await _settings.save(settings);

    final result = await _schedule(settings);
    return result.fold((failure) => Left(failure), (_) => Right(settings));
  }

  @override
  Future<Either<Failure, Unit>> reschedule() async {
    try {
      final settings = await _settings.load();
      return await _schedule(settings);
    } on Object catch (error, stackTrace) {
      return Left(
        Failure(
          'Hatırlatıcı ayarları okunamadı.',
          type: FailureType.storage,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<Either<Failure, Unit>> _schedule(ReminderSettings settings) async {
    try {
      await _notifications.cancelScheduled();
      if (!settings.isEnabled) return const Right(unit);

      final wordsResult = await _deck.fetchSession();
      if (wordsResult.isLeft()) {
        return wordsResult.fold(
          (failure) => Left(failure),
          (_) => const Left(Failure('Kelimeler yüklenemedi.')),
        );
      }

      final words = wordsResult.getOrElse(() => const <DeckWord>[]);
      final now = _now();

      final wordSlots = _buildWordSlots(words, settings, now);
      for (var index = 0; index < wordSlots.length; index++) {
        await _notifications.schedule(wordSlots[index], _wordIdBase + index);
      }

      final promptSlots = _buildPromptSlots(words.length, settings, now);
      for (var index = 0; index < promptSlots.length; index++) {
        await _notifications.schedule(
          promptSlots[index],
          _promptIdBase + index,
        );
      }

      return const Right(unit);
    } on Object catch (error, stackTrace) {
      return Left(
        Failure(
          'Hatırlatıcılar planlanamadı.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  List<ReminderSlot> _buildWordSlots(
    List<DeckWord> words,
    ReminderSettings settings,
    DateTime now,
  ) {
    if (words.isEmpty) return const <ReminderSlot>[];

    final midnight = DateTime(now.year, now.month, now.day);
    var start = midnight.add(Duration(minutes: settings.startMinutes));
    var end = midnight.add(Duration(minutes: settings.endMinutes));

    if (!end.isAfter(now)) {
      start = start.add(const Duration(days: 1));
      end = end.add(const Duration(days: 1));
    } else if (start.isBefore(now)) {
      start = now.add(const Duration(minutes: 1));
    }

    final windowMinutes = end.difference(start).inMinutes;
    if (windowMinutes <= 0) return const <ReminderSlot>[];

    final capacity = max(1, windowMinutes ~/ _minGapMinutes);
    final count = min(min(words.length, _maxScheduled), capacity);
    final step = windowMinutes / count;

    final slots = <ReminderSlot>[];
    var at = start;

    for (var index = 0; index < count; index++) {
      final word = words[index];
      slots.add(
        ReminderSlot(
          title: word.word,
          body: '${word.translation} • Tekrar zamanı',
          at: at,
        ),
      );
      if (index == count - 1) break;

      final latest = end.subtract(
        Duration(minutes: _minGapMinutes * (count - index - 1)),
      );
      final gap = step >= _maxGapMinutes
          ? _minGapMinutes +
                _random.nextInt(_maxGapMinutes - _minGapMinutes + 1)
          : _jitteredGap(step);

      var next = at.add(Duration(minutes: gap));
      final earliest = at.add(const Duration(minutes: _minGapMinutes));
      if (next.isBefore(earliest)) next = earliest;
      if (next.isAfter(latest)) next = latest;
      at = next;
    }

    return slots;
  }

  /// Prompts the user to open the app every cadence interval, counted from
  /// [now]. When the next prompt would land outside the window it moves to the
  /// start of the next window instead.
  List<ReminderSlot> _buildPromptSlots(
    int pendingWords,
    ReminderSettings settings,
    DateTime now,
  ) {
    final midnight = DateTime(now.year, now.month, now.day);
    var windowStart = midnight.add(Duration(minutes: settings.startMinutes));
    var windowEnd = midnight.add(Duration(minutes: settings.endMinutes));
    if (!windowEnd.isAfter(windowStart)) return const <ReminderSlot>[];

    final interval = _cadence.intervalFor(
      windowEnd.difference(windowStart).inMinutes,
    );

    var at = now.add(interval);
    if (!at.isBefore(windowEnd)) {
      windowStart = windowStart.add(const Duration(days: 1));
      windowEnd = windowEnd.add(const Duration(days: 1));
      at = windowStart;
    } else if (at.isBefore(windowStart)) {
      at = windowStart;
    }

    final body = pendingWords > 0
        ? '$pendingWords kelime seni bekliyor.'
        : 'Kelimelerini tekrar etme zamanı.';

    final slots = <ReminderSlot>[];
    while (at.isBefore(windowEnd)) {
      slots.add(ReminderSlot(title: _promptTitle, body: body, at: at));
      at = at.add(interval);
    }
    return slots;
  }

  /// Keeps the spacing close to [step] so a fixed count always fits the window.
  int _jitteredGap(double step) {
    final base = step.round();
    final jitter = (step * 0.2).round();
    if (jitter <= 0) {
      return base.clamp(_minGapMinutes, _maxGapMinutes).toInt();
    }

    final gap = base + _random.nextInt(jitter * 2 + 1) - jitter;
    return gap.clamp(_minGapMinutes, _maxGapMinutes).toInt();
  }
}
