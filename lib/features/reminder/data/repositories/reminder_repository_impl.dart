import 'dart:math';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../deck_session/deck_session.dart';
import '../data_sources/notification_data_source.dart';
import '../data_sources/reminder_settings_data_source.dart';
import '../models/reminder_settings.dart';
import '../models/reminder_slot.dart';
import 'reminder_repository.dart';

/// Binds today's deck words to randomly spaced times inside the user window.
///
/// Gaps are always between [_minGapMinutes] and [_maxGapMinutes]; words are
/// scheduled in deck order until the window is full.
class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(
    this._deck,
    this._settings,
    this._notifications, {
    Random? random,
    DateTime Function()? now,
  }) : _random = random ?? Random(),
       _now = now ?? DateTime.now;

  static const int _minGapMinutes = 10;
  static const int _maxGapMinutes = 120;
  static const int _maxScheduled = 50;
  static const int _notificationIdBase = 9100;

  final DeckRepository _deck;
  final ReminderSettingsDataSource _settings;
  final NotificationDataSource _notifications;
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
      final slots = _buildSlots(words, settings, _now());

      for (var index = 0; index < slots.length; index++) {
        await _notifications.schedule(
          slots[index],
          _notificationIdBase + index,
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

  List<ReminderSlot> _buildSlots(
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

    final slots = <ReminderSlot>[];
    var at = start;

    for (final word in words) {
      if (!at.isBefore(end) || slots.length >= _maxScheduled) break;

      slots.add(
        ReminderSlot(
          wordId: word.id,
          word: word.word,
          translation: word.translation,
          at: at,
        ),
      );

      final remaining = end.difference(at).inMinutes;
      if (remaining <= _minGapMinutes) break;

      final upper = remaining < _maxGapMinutes ? remaining : _maxGapMinutes;
      final gap =
          _minGapMinutes + _random.nextInt(upper - _minGapMinutes + 1);
      at = at.add(Duration(minutes: gap));
    }

    return slots;
  }
}
