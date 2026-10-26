import 'package:flutter/widgets.dart';

import '../design_system/design_system.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.secondaryForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
