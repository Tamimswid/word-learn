import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';

/// Back button, exercise name and "1 / 5" counter above the progress bar.
class ExerciseHeader extends StatelessWidget {
  const ExerciseHeader({
    super.key,
    required this.title,
    required this.position,
    required this.total,
    required this.progress,
    required this.onBack,
  });

  final String title;
  final int position;
  final int total;
  final double progress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              AppIconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: AppSpacing.xxl,
                ),
                tooltip: 'Ana ekrana dön',
                variant: AppIconButtonVariant.ghost,
                size: AppSpacing.xxxl + AppSpacing.xs,
                onPressed: onBack,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ),
              if (total > 0)
                Text(
                  '$position / $total',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: SizedBox(
              height: AppSpacing.xs,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: AppColors.secondary),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress.clamp(0, 1)),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value,
                        child: const ColoredBox(color: AppColors.primary),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
