import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// Reassuring line pinned under every exercise.
class ExerciseFooter extends StatelessWidget {
  const ExerciseFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.lg,
        AppSpacing.screen,
        AppSpacing.xxl + AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: AppSpacing.md + AppSpacing.xxs,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(width: AppSpacing.sm - AppSpacing.xxs),
          Text(
            'Küçük tekrar, kalıcı kelimeler.',
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
