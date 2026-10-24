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
      label: 'Süper hızlı',
      duration: '5–10 sn',
      iconAsset: AppAssets.practiceFast,
    ),
    QuickPracticeLevel(
      label: 'Kolay',
      duration: '15–20 sn',
      iconAsset: AppAssets.practiceEasy,
    ),
    QuickPracticeLevel(
      label: 'Orta',
      duration: '20–30 sn',
      iconAsset: AppAssets.practiceMedium,
    ),
    QuickPracticeLevel(
      label: 'Zor',
      duration: '30–45 sn',
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
                'Hızlı alıştırma',
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
                  Text('Tümü'),
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
