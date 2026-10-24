import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../data/models/deck_word.dart';

@immutable
class DeckState {
  const DeckState({
    this.words = const <DeckWord>[],
    this.index = 0,
    this.status = LoadStatus.idle,
    this.failure,
  });

  final List<DeckWord> words;
  final int index;
  final LoadStatus status;
  final Failure? failure;

  DeckWord? get current =>
      index >= 0 && index < words.length ? words[index] : null;

  int get total => words.length;

  int get position => index + 1;

  bool get isLoading => status == LoadStatus.loading;

  bool get isFinished =>
      status == LoadStatus.success && index >= words.length;

  DeckState copyWith({
    List<DeckWord>? words,
    int? index,
    LoadStatus? status,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return DeckState(
      words: words ?? this.words,
      index: index ?? this.index,
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
