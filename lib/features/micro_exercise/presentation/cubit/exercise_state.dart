import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../data/models/exercise_item.dart';

@immutable
class ExerciseAnswer {
  const ExerciseAnswer({
    required this.isCorrect,
    required this.correctAnswer,
    this.selected,
  });

  final bool isCorrect;
  final String correctAnswer;
  final String? selected;
}

@immutable
class ExerciseState {
  const ExerciseState({
    this.items = const <ExerciseItem>[],
    this.index = 0,
    this.status = LoadStatus.idle,
    this.failure,
    this.answer,
    this.correctCount = 0,
  });

  final List<ExerciseItem> items;
  final int index;
  final LoadStatus status;
  final Failure? failure;
  final ExerciseAnswer? answer;
  final int correctCount;

  ExerciseItem? get current =>
      index >= 0 && index < items.length ? items[index] : null;

  int get total => items.length;

  int get position => index + 1;

  double get progress => total == 0 ? 0 : ((index + 1) / total).clamp(0, 1);

  bool get isLoading => status == LoadStatus.loading;

  bool get isAnswered => answer != null;

  bool get isFinished => status == LoadStatus.success && index >= items.length;

  ExerciseState copyWith({
    List<ExerciseItem>? items,
    int? index,
    LoadStatus? status,
    Failure? failure,
    ExerciseAnswer? answer,
    int? correctCount,
    bool clearFailure = false,
    bool clearAnswer = false,
  }) {
    return ExerciseState(
      items: items ?? this.items,
      index: index ?? this.index,
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
      answer: clearAnswer ? null : answer ?? this.answer,
      correctCount: correctCount ?? this.correctCount,
    );
  }
}
