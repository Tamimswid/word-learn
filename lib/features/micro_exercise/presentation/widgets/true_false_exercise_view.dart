import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../data/models/exercise_item.dart';
import '../cubit/exercise_state.dart';
import 'highlighted_text.dart';

class TrueFalseExerciseView extends StatelessWidget {
  const TrueFalseExerciseView({
    super.key,
    required this.item,
    required this.answer,
    required this.onAnswer,
  });

  final TrueFalseExercise item;
  final ExerciseAnswer? answer;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    final sentenceStyle = AppTypography.headingLarge.copyWith(
      color: AppColors.foreground,
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Altı çizili kelime doğru kullanılmış mı?',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        HighlightedText(
          text: item.sentence,
          highlight: item.underlinedWord,
          style: sentenceStyle,
          highlightStyle: sentenceStyle.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primaryGlow,
            decorationThickness: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.huge + AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _AnswerButton(
                icon: Icons.close_rounded,
                baseColor: AppColors.destructive,
                baseBorder: AppBorders.sideDestructive,
                tone: _tone(sideIsTrue: false),
                onTap: answer == null ? () => onAnswer(false) : null,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _AnswerButton(
                icon: Icons.check_rounded,
                baseColor: AppColors.success,
                baseBorder: AppBorders.sideSuccess,
                tone: _tone(sideIsTrue: true),
                onTap: answer == null ? () => onAnswer(true) : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  _AnswerTone _tone({required bool sideIsTrue}) {
    final current = answer;
    if (current == null) return _AnswerTone.base;

    if (sideIsTrue == item.isCorrect) return _AnswerTone.correct;
    if (current.selected == (sideIsTrue ? 'true' : 'false')) {
      return _AnswerTone.wrong;
    }
    return _AnswerTone.muted;
  }
}

enum _AnswerTone { base, correct, wrong, muted }

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.icon,
    required this.baseColor,
    required this.baseBorder,
    required this.tone,
    this.onTap,
  });

  final IconData icon;
  final Color baseColor;
  final BorderSide baseBorder;
  final _AnswerTone tone;
  final VoidCallback? onTap;

  Color get _background => switch (tone) {
    _AnswerTone.correct => AppColors.successSoft,
    _AnswerTone.wrong => AppColors.destructiveSoft,
    _AnswerTone.base || _AnswerTone.muted => AppColors.secondary,
  };

  Color get _foreground => switch (tone) {
    _AnswerTone.base => baseColor,
    _AnswerTone.correct => AppColors.success,
    _AnswerTone.wrong => AppColors.destructive,
    _AnswerTone.muted => AppColors.mutedForeground,
  };

  BorderSide get _border => switch (tone) {
    _AnswerTone.base => baseBorder,
    _AnswerTone.correct => AppBorders.sideSuccess,
    _AnswerTone.wrong => AppBorders.sideDestructive,
    _AnswerTone.muted => AppBorders.side,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.huge * 2,
      child: Material(
        color: _background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: _border,
        ),
        child: InkWell(
          onTap: onTap,
          overlayColor: const WidgetStatePropertyAll(AppColors.foregroundFaint),
          child: Center(
            child: Icon(icon, size: AppSpacing.xxxl, color: _foreground),
          ),
        ),
      ),
    );
  }
}
