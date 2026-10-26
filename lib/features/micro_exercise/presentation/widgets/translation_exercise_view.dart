import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/exercise_item.dart';
import '../cubit/exercise_state.dart';
import 'exercise_option_tile.dart';

class TranslationExerciseView extends StatelessWidget {
  const TranslationExerciseView({
    super.key,
    required this.item,
    required this.answer,
    required this.onAnswer,
  });

  final TranslationExercise item;
  final ExerciseAnswer? answer;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    final sentenceStyle = AppTypography.headingMedium.copyWith(
      color: AppColors.foreground,
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Doğru Türkçe karşılığı seç.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl + AppSpacing.xs),
        HighlightedText(
          text: item.sentence,
          highlight: item.word,
          style: sentenceStyle,
          highlightStyle: sentenceStyle.copyWith(color: AppColors.primaryGlow),
        ),
        const SizedBox(height: AppSpacing.xxl + AppSpacing.md),
        for (var index = 0; index < item.options.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          ExerciseOptionTile(
            label: item.options[index],
            state: _stateFor(item.options[index]),
            onTap: answer == null ? () => onAnswer(item.options[index]) : null,
          ),
        ],
      ],
    );
  }

  ExerciseOptionState _stateFor(String option) {
    final current = answer;
    if (current == null) return ExerciseOptionState.idle;
    if (option == current.correctAnswer) return ExerciseOptionState.correct;
    if (option == current.selected) return ExerciseOptionState.wrong;
    return ExerciseOptionState.muted;
  }
}
