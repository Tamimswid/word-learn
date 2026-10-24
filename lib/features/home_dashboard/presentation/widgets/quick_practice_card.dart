import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/design_system/design_system.dart';

@immutable
class QuickPracticeLevel {
  const QuickPracticeLevel({
    required this.label,
    required this.duration,
    required this.iconAsset,
  });

  final String label;
  final String duration;
  final String iconAsset;
}

class QuickPracticeCard extends StatelessWidget {
  const QuickPracticeCard({super.key, required this.level, this.onTap});

  final QuickPracticeLevel level;
  final VoidCallback? onTap;

  static const double _height =
      AppSpacing.giant + AppSpacing.lg + AppSpacing.xxs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Material(
        color: AppColors.secondary,
        clipBehavior: Clip.antiAlias,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: onTap,
          overlayColor: const WidgetStatePropertyAll(AppColors.foregroundFaint),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                SvgPicture.asset(
                  level.iconAsset,
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        level.duration,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.overline.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
