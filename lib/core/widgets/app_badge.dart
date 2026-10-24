import 'package:flutter/material.dart';

import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

enum AppBadgeVariant { primary, neutral, outline, success, danger }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.primary,
    this.icon,
  });

  final String label;
  final AppBadgeVariant variant;
  final Widget? icon;

  Color get _background => switch (variant) {
    AppBadgeVariant.primary => AppColors.primarySoft,
    AppBadgeVariant.neutral => AppColors.secondary,
    AppBadgeVariant.outline => AppColors.transparent,
    AppBadgeVariant.success => AppColors.successSoft,
    AppBadgeVariant.danger => AppColors.destructiveSoft,
  };

  Color get _foreground => switch (variant) {
    AppBadgeVariant.primary => AppColors.primaryGlow,
    AppBadgeVariant.neutral => AppColors.secondaryForeground,
    AppBadgeVariant.outline => AppColors.mutedForeground,
    AppBadgeVariant.success => AppColors.success,
    AppBadgeVariant.danger => AppColors.destructive,
  };

  Color get _borderColor => variant == AppBadgeVariant.outline
      ? AppColors.border
      : AppColors.transparent;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.caption.copyWith(
      color: _foreground,
      fontWeight: FontWeight.w500,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xxs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: _foreground, size: 12),
              child: icon!,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }
}
