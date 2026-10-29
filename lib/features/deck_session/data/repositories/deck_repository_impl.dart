import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../data_sources/deck_data_source.dart';
import '../models/deck_word.dart';
import '../models/review_policy.dart';
import 'deck_repository.dart';

/// Builds today's review session with a light spaced-repetition schedule.
///
/// Due words come first, ranked by how often the user missed them; words that
/// were never shown fill the rest of the daily limit so a thin backlog does not
/// turn into an empty session. Words still inside their interval wait.
class DeckRepositoryImpl implements DeckRepository {
  DeckRepositoryImpl(this._source, {ReviewPolicy policy = ReviewPolicy.standard})
    : _policy = policy;

  final DeckDataSource _source;
  final ReviewPolicy _policy;

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

    final settings = settingsResult.getOrElse(() => const <String, dynamic>{});
    final wordRows = wordsResult.getOrElse(
      () => const <Map<String, dynamic>>[],
    );

    final now = DateTime.now();
    final limit = _sessionSize(settings['daily_notification_limit']);
    final words = wordRows.map(DeckWord.fromJson).toList(growable: false);

    final due = words.where((word) => _isDue(word, now)).toList()
      ..sort(_byPriority);
    final unseen = words.where((word) => _dueAt(word) == null).toList()
      ..sort(_byCreatedAt);

    final session = <DeckWord>[];
    final seenIds = <String>{};
    void take(Iterable<DeckWord> pool) {
      for (final word in pool) {
        if (session.length >= limit) return;
        if (!seenIds.add(word.id)) continue;
        session.add(word);
      }
    }

    take(due);
    take(unseen);

    return Right(session);
  }

  @override
  Future<Either<Failure, Unit>> recordAnswer(
    DeckWord word, {
    required bool known,
  }) {
    final masteryLevel = (word.masteryLevel + (known ? 1 : -1))
        .clamp(0, 5)
        .toInt();
    final reviewedAt = DateTime.now();

    return _source.updateProgress(
      word.id,
      successCount: word.successCount + (known ? 1 : 0),
      errorCount: word.errorCount + (known ? 0 : 1),
      masteryLevel: masteryLevel,
      reviewedAt: reviewedAt,
      nextReviewAt: reviewedAt.add(
        _policy.intervalAfter(known: known, masteryLevel: masteryLevel),
      ),
    );
  }

  static int _sessionSize(Object? value) {
    final raw = value is num ? value.toInt() : _fallbackSessionSize;
    return raw.clamp(_minSessionSize, _maxSessionSize).toInt();
  }

  /// Scheduled time; null marks a word that was never shown.
  DateTime? _dueAt(DeckWord word) {
    final nextReviewAt = word.nextReviewAt;
    if (nextReviewAt != null) return nextReviewAt;

    final lastReviewedAt = word.lastReviewedAt;
    if (lastReviewedAt == null) return null;

    // Rows written before `next_review_at` existed fall back to their level.
    return lastReviewedAt.add(_policy.intervalFor(word));
  }

  bool _isDue(DeckWord word, DateTime now) {
    final dueAt = _dueAt(word);
    return dueAt != null && !dueAt.isAfter(now);
  }

  int _byPriority(DeckWord a, DeckWord b) {
    final rate = _errorRate(b).compareTo(_errorRate(a));
    if (rate != 0) return rate;

    final errors = b.errorCount.compareTo(a.errorCount);
    if (errors != 0) return errors;

    final mastery = a.masteryLevel.compareTo(b.masteryLevel);
    if (mastery != 0) return mastery;

    final due = (_dueAt(a) ?? DateTime(0)).compareTo(_dueAt(b) ?? DateTime(0));
    if (due != 0) return due;

    return _byCreatedAt(a, b);
  }

  static double _errorRate(DeckWord word) {
    final answers = word.errorCount + word.successCount;
    if (answers == 0) return 0;
    return word.errorCount / answers;
  }

  static int _byCreatedAt(DeckWord a, DeckWord b) {
    return (a.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
      b.createdAt?.millisecondsSinceEpoch ?? 0,
    );
  }
}
