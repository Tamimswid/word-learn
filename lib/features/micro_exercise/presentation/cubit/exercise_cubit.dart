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

  void answerPronunciation(String recognized) {
    final item = state.current;
    if (item is! PronunciationExercise || state.isAnswered) return;

    final heard = recognized.trim();
    _record(
      isCorrect: _matchesPronunciation(heard, item.word),
      correctAnswer: item.word,
      selected: heard,
    );
  }

  void skipPronunciation() {
    final item = state.current;
    if (item is! PronunciationExercise || state.isAnswered) return;

    _record(isCorrect: false, correctAnswer: item.word);
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

  static bool _matchesPronunciation(String heard, String word) {
    final target = _normalizePronunciation(word);
    final spoken = _normalizePronunciation(heard);
    if (target.isEmpty || spoken.isEmpty) return false;
    if (spoken == target) return true;
    if (target.contains(' ')) return spoken.contains(target);
    return spoken.split(' ').contains(target);
  }

  static String _normalizePronunciation(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9' ]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
