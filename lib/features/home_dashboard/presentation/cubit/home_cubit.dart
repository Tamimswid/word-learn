import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../../word_management/data/repositories/word_repository.dart';
import '../../data/models/home_snapshot.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository, this._words)
    : super(HomeState(snapshot: HomeSnapshot.zero()));

  final HomeRepository _repository;
  final WordRepository _words;

  Future<void> load() async {
    if (state.isLoading) return;

    emit(state.copyWith(status: LoadStatus.loading, clearFailure: true));

    final result = await _repository.fetchSnapshot();

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: LoadStatus.failure, failure: failure),
      ),
      (snapshot) => emit(
        state.copyWith(
          status: LoadStatus.success,
          snapshot: snapshot,
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
      ),
    );
  }

  Future<Failure?> deleteWord(LearnedWord word) async {
    final snapshot = state.snapshot;

    final index = snapshot.recentWords.indexWhere(
      (candidate) => candidate.id == word.id,
    );
    if (index < 0) return null;

    final remaining = <LearnedWord>[...snapshot.recentWords]..removeAt(index);
    final points = _shiftPoints(snapshot, word.createdAt, -1);
    emit(
      state.copyWith(
        snapshot: snapshot.copyWith(
          learnedCount: _decrement(snapshot.learnedCount),
          recentWords: remaining,
          weeklyPoints: points.weekly,
          monthlyPoints: points.monthly,
        ),
      ),
    );

    final result = await _words.deleteWord(word.id);

    if (isClosed) return null;

    return result.fold(
      (failure) {
        final current = state.snapshot;
        final restored = <LearnedWord>[...current.recentWords];
        restored.insert(
          index > restored.length ? restored.length : index,
          word,
        );
        final restoredPoints = _shiftPoints(current, word.createdAt, 1);
        emit(
          state.copyWith(
            snapshot: current.copyWith(
              learnedCount: current.learnedCount + 1,
              recentWords: restored,
              weeklyPoints: restoredPoints.weekly,
              monthlyPoints: restoredPoints.monthly,
            ),
          ),
        );
        return failure;
      },
      (_) => null,
    );
  }

  Future<Failure?> updateSessionSize(int size) async {
    final snapshot = state.snapshot;
    if (snapshot.sessionSize == size) return null;

    final previousSize = snapshot.sessionSize;
    emit(state.copyWith(snapshot: snapshot.copyWith(sessionSize: size)));

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
