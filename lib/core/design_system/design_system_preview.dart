import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Development preview of the design-system tokens and shared widgets.
class DesignSystemPreview extends StatelessWidget {
  const DesignSystemPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Kelime', style: AppTypography.titleSmall),
                  const Spacer(),
                  const StreakIndicator(days: 5),
                  const SizedBox(width: AppSpacing.md),
                  AppIconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    tooltip: 'Bildirim ayarları',
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Bugün de bir kelime.', style: AppTypography.headingMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Küçük tekrar, kalıcı kelimeler.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBadge(label: 'Süper hızlı'),
                    const SizedBox(height: AppSpacing.md),
                    Text('serendipity', style: AppTypography.displayLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'mutlu rastlantı',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.secondaryForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Başla',
                icon: const Icon(Icons.arrow_forward_rounded),
                expanded: true,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Daha sonra',
                variant: AppButtonVariant.secondary,
                expanded: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
