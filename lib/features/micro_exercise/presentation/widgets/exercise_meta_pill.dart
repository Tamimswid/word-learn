import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';

/// Difficulty pill and estimated duration shown above each exercise.
class ExerciseMetaPill extends StatelessWidget {
  const ExerciseMetaPill({
    super.key,
    required this.level,
    required this.duration,
  });

  final String level;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.sm,
      children: [
        AppBadge(label: level),
        Icon(
          Icons.schedule_rounded,
          size: AppSpacing.md,
          color: AppColors.mutedForeground,
        ),
        Text(
          duration,
          style: AppTypography.caption.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
