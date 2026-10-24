import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/exercise_item.dart';
import '../cubit/exercise_cubit.dart';
import '../cubit/exercise_state.dart';
import 'fill_blank_exercise_view.dart';
import 'matching_exercise_view.dart';
import 'sentence_exercise_view.dart';
import 'spelling_exercise_view.dart';
import 'translation_exercise_view.dart';
import 'true_false_exercise_view.dart';

/// Renders the view matching [item]'s exercise type.
class ExerciseItemView extends StatelessWidget {
  const ExerciseItemView({super.key, required this.item, required this.answer});

  final ExerciseItem item;
  final ExerciseAnswer? answer;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExerciseCubit>();

    return switch (item) {
      TrueFalseExercise exercise => TrueFalseExerciseView(
        item: exercise,
        answer: answer,
        onAnswer: (saysCorrect) =>
            cubit.answerTrueFalse(saysCorrect: saysCorrect),
      ),
      MatchingExercise exercise => MatchingExerciseView(
        item: exercise,
        answer: answer,
        onCompleted: ({required hadMistake}) =>
            cubit.answerMatching(hadMistake: hadMistake),
      ),
      FillBlankExercise exercise => FillBlankExerciseView(
        item: exercise,
        answer: answer,
        onAnswer: cubit.answerChoice,
      ),
      SpellingExercise exercise => SpellingExerciseView(
        item: exercise,
        answer: answer,
        onSubmit: cubit.answerSpelling,
      ),
      TranslationExercise exercise => TranslationExerciseView(
        item: exercise,
        answer: answer,
        onAnswer: cubit.answerChoice,
      ),
      SentenceExercise exercise => SentenceExerciseView(
        item: exercise,
        answer: answer,
        onSubmit: cubit.answerSentence,
      ),
    };
  }
}
