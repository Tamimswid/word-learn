import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../data_sources/deck_data_source.dart';
import '../models/deck_word.dart';
import 'deck_repository.dart';

/// Builds today's deck with the 50/30/20 mix from the product brief:
/// 50% new or overdue words, 30% learning words, 20% mastered words.
class DeckRepositoryImpl implements DeckRepository {
  DeckRepositoryImpl(this._source);

  final DeckDataSource _source;

  static const int _fallbackSessionSize = 10;
  static const int _minSessionSize = 5;
  static const int _maxSessionSize = 50;

  @override
  Future<Either<Failure, List<DeckWord>>> fetchSession() async {
    final (settingsResult, wordsResult) = await (
      _source.fetchSettings(),
      _source.fetchWords(),
    ).wait;

    final failure =
        settingsResult.fold<Failure?>((failure) => failure, (_) => null) ??
        wordsResult.fold<Failure?>((failure) => failure, (_) => null);
    if (failure != null) return Left(failure);

    final settings = settingsResult.getOrElse(
      () => const <String, dynamic>{},
    );
    final wordRows = wordsResult.getOrElse(
      () => const <Map<String, dynamic>>[],
    );

    final now = DateTime.now();
    final sessionSize = _sessionSize(settings['daily_notification_limit']);
    final due = wordRows
        .map(DeckWord.fromJson)
        .where((word) => _isDue(word, now))
        .toList(growable: false);

    if (due.isEmpty) return const Right(<DeckWord>[]);

    final critical =
        due.where((word) => word.masteryLevel <= 1).toList()
          ..sort(_byUrgency);
    final learning =
        due
            .where(
              (word) => word.masteryLevel == 2 || word.masteryLevel == 3,
            )
            .toList()
          ..sort(_byUrgency);
    final mastered =
        due.where((word) => word.masteryLevel >= 4).toList()
          ..sort(_byUrgency);

    final picked = <DeckWord>[];
    final pickedIds = <String>{};
    void take(List<DeckWord> pool, int count) {
      for (final word in pool) {
        if (picked.length >= sessionSize || count <= 0) return;
        if (!pickedIds.add(word.id)) continue;
        picked.add(word);
        count--;
      }
    }

    take(critical, (sessionSize * 0.5).round());
    take(learning, (sessionSize * 0.3).round());
    take(mastered, sessionSize);
    take(critical, sessionSize);
    take(learning, sessionSize);

    return Right(picked);
  }

  @override
  Future<Either<Failure, Unit>> recordAnswer(
    DeckWord word, {
    required bool known,
  }) {
    return _source.updateProgress(
      word.id,
      successCount: word.successCount + (known ? 1 : 0),
      errorCount: word.errorCount + (known ? 0 : 1),
      masteryLevel: (word.masteryLevel + (known ? 1 : -1))
          .clamp(0, 5)
          .toInt(),
      reviewedAt: DateTime.now(),
    );
  }

  static int _sessionSize(Object? value) {
    final raw = value is num ? value.toInt() : _fallbackSessionSize;
    return raw.clamp(_minSessionSize, _maxSessionSize).toInt();
  }

  static bool _isDue(DeckWord word, DateTime now) {
    final lastReviewedAt = word.lastReviewedAt;
    if (lastReviewedAt == null) return true;

    final interval = switch (word.masteryLevel) {
      <= 1 => const Duration(hours: 4),
      2 || 3 => const Duration(hours: 24),
      _ => const Duration(days: 3),
    };

    return now.difference(lastReviewedAt) >= interval;
  }

  static int _byUrgency(DeckWord a, DeckWord b) {
    final errors = b.errorCount.compareTo(a.errorCount);
    if (errors != 0) return errors;

    final mastery = a.masteryLevel.compareTo(b.masteryLevel);
    if (mastery != 0) return mastery;

    final lastReviewed = (a.lastReviewedAt?.millisecondsSinceEpoch ?? 0)
        .compareTo(b.lastReviewedAt?.millisecondsSinceEpoch ?? 0);
    if (lastReviewed != 0) return lastReviewed;

    return (a.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
      b.createdAt?.millisecondsSinceEpoch ?? 0,
    );
  }
}
