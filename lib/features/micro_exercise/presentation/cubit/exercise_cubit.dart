import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/load_status.dart';
import '../../data/models/exercise_item.dart';
import '../../data/repositories/exercise_repository.dart';
import 'exercise_state.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  ExerciseCubit(this._repository) : super(const ExerciseState());

  final ExerciseRepository _repository;

  Future<void> load({required List<String> seedIds}) async {
    if (state.isLoading) return;

    emit(const ExerciseState(status: LoadStatus.loading));

    final result = await _repository.buildSession(seedIds: seedIds);

    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(ExerciseState(status: LoadStatus.failure, failure: failure)),
      (items) => emit(ExerciseState(items: items, status: LoadStatus.success)),
    );
  }

  void answerTrueFalse({required bool saysCorrect}) {
    final item = state.current;
    if (item is! TrueFalseExercise || state.isAnswered) return;

    _record(
      isCorrect: saysCorrect == item.isCorrect,
      correctAnswer: item.isCorrect ? 'Doğru' : 'Yanlış',
      selected: saysCorrect ? 'true' : 'false',
    );
  }

  void answerChoice(String option) {
    final item = state.current;
    if (state.isAnswered) return;

    switch (item) {
      case FillBlankExercise():
        _record(
          isCorrect: option == item.correctAnswer,
          correctAnswer: item.correctAnswer,
          selected: option,
        );
      case TranslationExercise():
        _record(
          isCorrect: option == item.correctAnswer,
          correctAnswer: item.correctAnswer,
          selected: option,
        );
      default:
        return;
    }
  }

  void answerSpelling(String value) {
    final item = state.current;
    if (item is! SpellingExercise || state.isAnswered) return;

    final answer = value.trim().toLowerCase();
    _record(
      isCorrect: answer == item.word,
      correctAnswer: item.word,
      selected: answer,
    );
  }

  void answerSentence(List<String> tokens) {
    final item = state.current;
    if (item is! SentenceExercise || state.isAnswered) return;

    final answer = tokens.join(' ').trim();
    _record(
      isCorrect: answer.toLowerCase() == item.correctSentence.toLowerCase(),
      correctAnswer: item.correctSentence,
      selected: answer,
    );
  }

  void answerMatching({required bool hadMistake}) {
    final item = state.current;
    if (item is! MatchingExercise || state.isAnswered) return;

    _record(
      isCorrect: !hadMistake,
      correctAnswer: item.pairs
          .map((pair) => '${pair.word} – ${pair.translation}')
          .join(', '),
    );
  }

  void next() {
    if (!state.isAnswered) return;

    emit(state.copyWith(index: state.index + 1, clearAnswer: true));
  }

  void _record({
    required bool isCorrect,
    required String correctAnswer,
    String? selected,
  }) {
    emit(
      state.copyWith(
        answer: ExerciseAnswer(
          isCorrect: isCorrect,
          correctAnswer: correctAnswer,
          selected: selected,
        ),
        correctCount: state.correctCount + (isCorrect ? 1 : 0),
      ),
    );
  }
}
