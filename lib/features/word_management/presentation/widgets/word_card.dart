import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/word_summary.dart';

class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.word});

  final WordSummary word;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge(
                label: '#${word.rank}',
                variant: AppBadgeVariant.neutral,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TapToSpeak(
                      text: word.word,
                      child: Text(
                        word.word,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    if (word.translation.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        word.translation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (word.exampleSentence.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                color: AppColors.muted,
                borderRadius: AppRadius.smAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: AppSpacing.lg,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TapToSpeak(
                          text: word.exampleSentence,
                          tooltip: 'Cümleyi dinle',
                          child: HighlightedText(
                            text: word.exampleSentence,
                            highlight: word.word,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondaryForeground,
                            ),
                          ),
                        ),
                        if (word.sentenceTranslation.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            word.sentenceTranslation,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                        if (word.arabicSentence.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TapToSpeak(
                              text: word.arabicSentence,
                              language: 'ar-SA',
                              tooltip: 'Arapça cümleyi dinle',
                              child: HighlightedText(
                                text: word.arabicSentence,
                                highlightIndex: word.wordIndex,
                                textDirection: TextDirection.rtl,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              AppBadge(
                label: '${word.successCount} doğru',
                variant: AppBadgeVariant.success,
                icon: const Icon(Icons.check_circle_rounded),
              ),
              AppBadge(
                label: '${word.errorCount} yanlış',
                variant: AppBadgeVariant.danger,
                icon: const Icon(Icons.cancel_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
