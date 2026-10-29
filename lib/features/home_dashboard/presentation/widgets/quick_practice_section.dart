import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import 'quick_practice_card.dart';

class QuickPracticeSection extends StatelessWidget {
  const QuickPracticeSection({
    super.key,
    required this.onSeeAll,
    required this.onLevelTap,
  });

  final VoidCallback onSeeAll;
  final VoidCallback onLevelTap;

  static const List<QuickPracticeLevel> _levels = <QuickPracticeLevel>[
    QuickPracticeLevel(
      label: 'فائق السرعة',
      duration: '5–10 ث',
      iconAsset: AppAssets.practiceFast,
    ),
    QuickPracticeLevel(
      label: 'سهل',
      duration: '15–20 ث',
      iconAsset: AppAssets.practiceEasy,
    ),
    QuickPracticeLevel(
      label: 'متوسط',
      duration: '20–30 ث',
      iconAsset: AppAssets.practiceMedium,
    ),
    QuickPracticeLevel(
      label: 'صعب',
      duration: '30–45 ث',
      iconAsset: AppAssets.practiceHard,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'تدريب سريع',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.foreground,
                ),
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('الكل'),
                  SizedBox(width: AppSpacing.xs),
                  Icon(Icons.arrow_forward_rounded, size: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var index = 0; index < _levels.length; index += 2) ...[
          if (index > 0) const SizedBox(height: AppSpacing.sm),
          Row(
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                child: QuickPracticeCard(
                  level: _levels[index],
                  onTap: onLevelTap,
                ),
              ),
              Expanded(
                child: QuickPracticeCard(
                  level: _levels[index + 1],
                  onTap: onLevelTap,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
