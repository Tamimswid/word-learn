import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../word_management/presentation/dialogs/delete_word_dialog.dart';
import '../../data/models/home_snapshot.dart';

class RecentWordsSection extends StatelessWidget {
  const RecentWordsSection({
    super.key,
    required this.words,
    required this.isLoading,
    required this.onSeeAll,
    required this.onDeleted,
  });

  final List<LearnedWord> words;
  final bool isLoading;
  final VoidCallback onSeeAll;
  final ValueChanged<LearnedWord> onDeleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Son öğrenilenler',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.foreground,
                ),
              ),
            ),
            if (words.isNotEmpty)
              TextButton(
                onPressed: onSeeAll,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tümünü gör'),
                    SizedBox(width: AppSpacing.xs),
                    Icon(Icons.arrow_forward_rounded, size: AppSpacing.lg),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (isLoading && words.isEmpty)
          const SizedBox.shrink()
        else if (words.isEmpty)
          const _EmptyWords()
        else
          for (var index = 0; index < words.length; index++)
            _AnimatedWordRow(
              key: ValueKey(words[index].id),
              index: index,
              child: _WordRow(
                word: words[index],
                onDeleted: () => onDeleted(words[index]),
                onConfirmDelete: () =>
                    showDeleteWordDialog(context, words[index].word),
              ),
            ),
      ],
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({
    required this.word,
    required this.onDeleted,
    required this.onConfirmDelete,
  });

  final LearnedWord word;
  final VoidCallback onDeleted;
  final Future<bool> Function() onConfirmDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Dismissible(
        key: ValueKey(word.id),
        direction: DismissDirection.startToEnd,
        background: const _DeleteBackground(),
        confirmDismiss: (_) => onConfirmDelete(),
        onDismissed: (_) => onDeleted(),
        child: AppCard(
          radius: AppRadius.md,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (word.word.isNotEmpty)
                    Flexible(
                      child: TapToSpeak(
                        text: word.word,
                        child: Text(
                          word.word,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                    ),
                  if (word.word.isNotEmpty && word.translation.isNotEmpty)
                    const SizedBox(width: AppSpacing.sm),
                  if (word.translation.isNotEmpty)
                    Flexible(
                      child: Text(
                        word.translation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                ],
              ),
              if (word.exampleSentence.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TapToSpeak(
                              text: word.exampleSentence,
                              tooltip: 'Cümleyi dinle',
                              child: HighlightedText(
                                text: word.exampleSentence,
                                highlight: word.word,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.secondaryForeground,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (word.sentenceTranslation.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                word.sentenceTranslation,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                            if (word.arabicSentence.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              TapToSpeak(
                                text: word.arabicSentence,
                                language: 'ar-SA',
                                tooltip: 'Arapça cümleyi dinle',
                                child: HighlightedText(
                                  text: word.arabicSentence,
                                  highlightIndex: word.wordIndex,
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.mutedForeground,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedWordRow extends StatefulWidget {
  const _AnimatedWordRow({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_AnimatedWordRow> createState() => _AnimatedWordRowState();
}

class _AnimatedWordRowState extends State<_AnimatedWordRow>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 280);
  static const Duration _stagger = Duration(milliseconds: 45);

  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _play();
  }

  Future<void> _play() async {
    await Future<void>.delayed(_stagger * widget.index.clamp(0, 6));
    if (!mounted) return;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.destructiveSoft,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            size: AppSpacing.lg,
            color: AppColors.destructive,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Sil',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.destructive,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWords extends StatelessWidget {
  const _EmptyWords();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.empty,
              width: AppSpacing.huge * 4,
              height: AppSpacing.huge * 4,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Empty',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
