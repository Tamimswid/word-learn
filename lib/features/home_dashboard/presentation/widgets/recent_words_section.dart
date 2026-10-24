import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/home_snapshot.dart';
import '../dialogs/delete_word_dialog.dart';

class RecentWordsSection extends StatelessWidget {
  const RecentWordsSection({
    super.key,
    required this.words,
    required this.isLoading,
    required this.onAdd,
    required this.onDeleted,
  });

  final List<LearnedWord> words;
  final bool isLoading;
  final VoidCallback onAdd;
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
              AppIconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Kelime ekle',
                variant: AppIconButtonVariant.outline,
                onPressed: onAdd,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (isLoading && words.isEmpty)
          const SizedBox.shrink()
        else if (words.isEmpty)
          _EmptyWords(onAdd: onAdd)
        else
          for (var index = 0; index < words.length; index++)
            _AnimatedWordRow(
              key: ValueKey(words[index].id),
              index: index,
              child: _WordRow(
                word: words[index],
                onDeleted: () => onDeleted(words[index]),
                onConfirmDelete: () =>
                    showDeleteWordDialog(context, words[index]),
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
    return Dismissible(
      key: ValueKey(word.id),
      direction: DismissDirection.startToEnd,
      background: const _DeleteBackground(),
      confirmDismiss: (_) => onConfirmDelete(),
      onDismissed: (_) => onDeleted(),
      child: Container(
        decoration: const BoxDecoration(border: AppBorders.bottom),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.listRow),
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (word.word.isNotEmpty)
                    Flexible(
                      child: Text(
                        word.word,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.foreground,
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
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.check_circle_rounded,
              size: AppSpacing.lg,
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedWordRow extends StatefulWidget {
  const _AnimatedWordRow({
    super.key,
    required this.index,
    required this.child,
  });

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
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
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
        borderRadius: AppRadius.smAll,
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
  const _EmptyWords({required this.onAdd});

  final VoidCallback onAdd;

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
            const SizedBox(height: AppSpacing.lg),
            AppAddButton(onPressed: onAdd),
          ],
        ),
      ),
    );
  }
}
