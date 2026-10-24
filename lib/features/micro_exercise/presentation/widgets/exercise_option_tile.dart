import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// Full-width answer row used by the gap-fill and translation exercises.
enum ExerciseOptionState { idle, correct, wrong, muted }

class ExerciseOptionTile extends StatelessWidget {
  const ExerciseOptionTile({
    super.key,
    required this.label,
    this.state = ExerciseOptionState.idle,
    this.onTap,
  });

  final String label;
  final ExerciseOptionState state;
  final VoidCallback? onTap;

  Color get _background => switch (state) {
    ExerciseOptionState.idle ||
    ExerciseOptionState.muted => AppColors.secondary,
    ExerciseOptionState.correct => AppColors.successSoft,
    ExerciseOptionState.wrong => AppColors.destructiveSoft,
  };

  Color get _foreground => switch (state) {
    ExerciseOptionState.idle => AppColors.secondaryForeground,
    ExerciseOptionState.muted => AppColors.mutedForeground,
    ExerciseOptionState.correct => AppColors.success,
    ExerciseOptionState.wrong => AppColors.destructive,
  };

  BorderSide get _border => switch (state) {
    ExerciseOptionState.correct => AppBorders.sideSuccess,
    ExerciseOptionState.wrong => AppBorders.sideDestructive,
    _ => AppBorders.side,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.giant,
      width: double.infinity,
      child: Material(
        color: _background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: _border,
        ),
        child: InkWell(
          onTap: onTap,
          overlayColor: const WidgetStatePropertyAll(AppColors.foregroundFaint),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(color: _foreground),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
