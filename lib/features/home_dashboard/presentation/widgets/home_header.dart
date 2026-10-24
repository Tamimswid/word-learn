import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greetingName,
    required this.streakDays,
    required this.onOpenSettings,
  });

  final String greetingName;
  final int streakDays;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final greeting = greetingName.isEmpty
        ? 'Merhaba'
        : 'Merhaba, $greetingName';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: AppSpacing.xxl + AppSpacing.xs,
              height: AppSpacing.xxl + AppSpacing.xs,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.lgAll,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: AppSpacing.lg,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Kelime',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const Spacer(),
            AppIconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Oturum ayarları',
              onPressed: onOpenSettings,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bugün de bir kelime.',
                    style: AppTypography.headingMedium.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: StreakIndicator(days: streakDays),
            ),
          ],
        ),
      ],
    );
  }
}
