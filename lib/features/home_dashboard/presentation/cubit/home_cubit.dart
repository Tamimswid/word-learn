import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../../deck_session/deck_session.dart';
import '../../../word_management/data/repositories/word_repository.dart';
import '../../data/models/home_snapshot.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository, this._words, this._deck)
    : super(HomeState(snapshot: HomeSnapshot.zero()));

  final HomeRepository _repository;
  final WordRepository _words;
  final DeckRepository _deck;

  Future<void> load() async {
    if (state.isLoading) return;

    emit(state.copyWith(status: LoadStatus.loading, clearFailure: true));

    final (snapshotResult, sessionResult) = await (
      _repository.fetchSnapshot(),
      _deck.fetchSession(),
    ).wait;

    if (isClosed) return;

    snapshotResult.fold(
      (failure) => emit(
        state.copyWith(status: LoadStatus.failure, failure: failure),
      ),
      (snapshot) => emit(
        state.copyWith(
          status: LoadStatus.success,
          snapshot: snapshot,
          sessionWords: _toDisplayWords(
            sessionResult.getOrElse(() => const <DeckWord>[]),
            snapshot.sessionSize,
          ),
          clearFailure: true,
        ),
      ),
    );
  }

  void addWord(LearnedWord word) {
    final snapshot = state.snapshot;

    final recentWords = <LearnedWord>[word, ...snapshot.recentWords]
        .take(HomeSnapshot.recentWordLimit)
        .toList(growable: false);

    final points = _shiftPoints(snapshot, word.createdAt, 1);

    emit(
      state.copyWith(
        snapshot: snapshot.copyWith(
          learnedCount: snapshot.learnedCount + 1,
          recentWords: recentWords,
          weeklyPoints: points.weekly,
          monthlyPoints: points.monthly,
        ),
        sessionWords: <LearnedWord>[word, ...state.sessionWords]
            .take(snapshot.sessionSize)
            .toList(growable: false),
      ),
    );
  }

  Future<Failure?> deleteWord(LearnedWord word) async {
    final snapshot = state.snapshot;

    final hasWord =
        state.sessionWords.any((candidate) => candidate.id == word.id) ||
        snapshot.recentWords.any((candidate) => candidate.id == word.id);
    if (!hasWord) return null;

    final points = _shiftPoints(snapshot, word.createdAt, -1);
    emit(
      state.copyWith(
        snapshot: snapshot.copyWith(
          learnedCount: _decrement(snapshot.learnedCount),
          recentWords: _without(snapshot.recentWords, word.id),
          weeklyPoints: points.weekly,
          monthlyPoints: points.monthly,
        ),
        sessionWords: _without(state.sessionWords, word.id),
      ),
    );

    final result = await _words.deleteWord(word.id);

    if (isClosed) return null;

    final failure = result.fold<Failure?>((failure) => failure, (_) => null);
    if (failure != null) {
      // The optimistic removal has to be undone from server state.
      await load();
      return failure;
    }

    return null;
  }

  Future<Failure?> updateSessionSize(int size) async {
    final snapshot = state.snapshot;
    if (snapshot.sessionSize == size) return null;

    final previousSize = snapshot.sessionSize;
    emit(
      state.copyWith(
        snapshot: snapshot.copyWith(sessionSize: size),
        sessionWords: state.sessionWords
            .take(size)
            .toList(growable: false),
      ),
    );

    final result = await _repository.updateSessionSize(size);

    if (isClosed) return null;

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            snapshot: state.snapshot.copyWith(sessionSize: previousSize),
          ),
        );
        return failure;
      },
      (_) => null,
    );
  }

  static List<LearnedWord> _toDisplayWords(List<DeckWord> words, int limit) {
    return words
        .take(limit)
        .map(
          (word) => LearnedWord(
            id: word.id,
            word: word.word,
            translation: word.translation,
            exampleSentence: word.exampleSentence,
            arabicSentence: word.arabicSentence,
            wordIndex: word.wordIndex,
            createdAt: word.createdAt,
          ),
        )
        .toList(growable: false);
  }

  static List<LearnedWord> _without(List<LearnedWord> words, String id) {
    return <LearnedWord>[
      for (final word in words)
        if (word.id != id) word,
    ];
  }

  static int _decrement(int value) => value > 0 ? value - 1 : 0;

  /// Keeps the chart in sync with an add/delete without waiting for a reload.
  static ({List<ActivityPoint> weekly, List<ActivityPoint> monthly})
  _shiftPoints(HomeSnapshot snapshot, DateTime? date, int delta) {
    final now = DateTime.now();
    final day = DateTime(
      date?.year ?? now.year,
      date?.month ?? now.month,
      date?.day ?? now.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekIndex = day.difference(weekStart).inDays;

    final monthStart = today.subtract(const Duration(days: 27));
    final daysSinceMonthStart = day.difference(monthStart).inDays;
    final monthIndex = daysSinceMonthStart < 0 ? -1 : daysSinceMonthStart ~/ 7;

    return (
      weekly: _shiftPoint(snapshot.weeklyPoints, weekIndex, delta),
      monthly: _shiftPoint(snapshot.monthlyPoints, monthIndex, delta),
    );
  }

  static List<ActivityPoint> _shiftPoint(
    List<ActivityPoint> points,
    int index,
    int delta,
  ) {
    if (index < 0 || index >= points.length) return points;

    return <ActivityPoint>[
      for (var i = 0; i < points.length; i++)
        i == index
            ? ActivityPoint(
                label: points[i].label,
                value: (points[i].value + delta)
                    .clamp(0, double.infinity)
                    .toDouble(),
                isCurrent: points[i].isCurrent,
              )
            : points[i],
    ];
  }
}
