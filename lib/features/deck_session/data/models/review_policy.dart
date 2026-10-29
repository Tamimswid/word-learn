import 'deck_word.dart';

/// Spaced-repetition intervals in one place so the schedule can be tuned (or
/// later driven by user settings) without touching the selection code.
class ReviewPolicy {
  const ReviewPolicy({
    this.unknownInterval = const Duration(minutes: 10),
    this.knownIntervals = defaultKnownIntervals,
  });

  /// Default cadence: answer correctly, wait 3 days; each further correct
  /// answer in a row stretches the gap (7 → 14 → 30 → 60 days).
  static const List<Duration> defaultKnownIntervals = <Duration>[
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
    Duration(days: 60),
  ];

  static const ReviewPolicy standard = ReviewPolicy();

  final Duration unknownInterval;
  final List<Duration> knownIntervals;

  /// Interval to store after answering; [masteryLevel] is the level the word
  /// will have after that answer (0–5).
  Duration intervalAfter({required bool known, required int masteryLevel}) {
    if (!known) return unknownInterval;

    final index = (masteryLevel - 1).clamp(0, knownIntervals.length - 1);
    return knownIntervals[index];
  }

  /// Interval assumed for a word whose stored schedule predates
  /// [DeckWord.nextReviewAt].
  Duration intervalFor(DeckWord word) {
    return intervalAfter(
      known: word.masteryLevel > 0,
      masteryLevel: word.masteryLevel,
    );
  }
}
