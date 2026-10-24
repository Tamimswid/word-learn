import 'package:flutter/material.dart';

import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

class StreakIndicator extends StatelessWidget {
  const StreakIndicator({
    super.key,
    required this.days,
    this.label,
    this.showIcon = true,
    this.icon = Icons.local_fire_department_rounded,
  });

  final int days;
  final String? label;
  final bool showIcon;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isActive = days > 0;
    final color = isActive ? AppColors.primaryGlow : AppColors.mutedForeground;
    final text = label ?? '$days gün';

    return Semantics(
      label: '$days günlük seri',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(text, style: AppTypography.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
