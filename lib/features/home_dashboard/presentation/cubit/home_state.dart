import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../data/models/home_snapshot.dart';

@immutable
class HomeState {
  const HomeState({
    required this.snapshot,
    this.sessionWords = const <LearnedWord>[],
    this.status = LoadStatus.idle,
    this.failure,
  });

  final HomeSnapshot snapshot;

  /// Today's filtered words, capped at the daily session size.
  final List<LearnedWord> sessionWords;
  final LoadStatus status;
  final Failure? failure;

  bool get isLoading => status == LoadStatus.loading;

  HomeState copyWith({
    LoadStatus? status,
    HomeSnapshot? snapshot,
    List<LearnedWord>? sessionWords,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      sessionWords: sessionWords ?? this.sessionWords,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}
