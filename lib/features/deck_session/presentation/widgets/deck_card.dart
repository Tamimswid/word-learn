import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../data/models/deck_word.dart';

/// A single word card. Tapping flips it between the prompt and the answer,
/// while [dragProgress] reveals the swipe stamps.
class DeckCard extends StatefulWidget {
  const DeckCard({
    super.key,
    required this.word,
    this.interactive = false,
    this.dragProgress = 0,
  });

  final DeckWord word;
  final bool interactive;

  /// -1 (swiped left / unknown) .. 1 (swiped right / known).
  final double dragProgress;

  @override
  State<DeckCard> createState() => _DeckCardState();
}

class _DeckCardState extends State<DeckCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_flip.value < 0.5) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.dragProgress.abs().clamp(0.0, 1.0);

    return Semantics(
      button: widget.interactive,
      label: widget.word.word,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: widget.interactive ? _toggleFlip : null,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: _flip,
                builder: (context, _) => _buildFlippableCard(),
              ),
              if (widget.interactive && progress > 0.01) _buildStamp(progress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlippableCard() {
    final angle = _flip.value * math.pi;
    final showBack = angle > math.pi / 2;
    final content = showBack
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(math.pi),
            child: _DeckCardBack(word: widget.word),
          )
        : _DeckCardFront(word: widget.word);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(angle),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.xlAll,
          border: Border.fromBorderSide(AppBorders.side),
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.xlAll,
          child: content,
        ),
      ),
    );
  }

  Widget _buildStamp(double progress) {
    final known = widget.dragProgress > 0;

    return Positioned(
      top: AppSpacing.card,
      left: known ? AppSpacing.card : null,
      right: known ? null : AppSpacing.card,
      child: Opacity(
        opacity: progress,
        child: Transform.rotate(
          angle: known ? -0.12 : 0.12,
          child: AppBadge(
            label: known ? 'BİLDİM' : 'BİLMEDİM',
            variant: known ? AppBadgeVariant.success : AppBadgeVariant.danger,
            icon: Icon(
              known ? Icons.check_rounded : Icons.close_rounded,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckCardFront extends StatelessWidget {
  const _DeckCardFront({required this.word});

  final DeckWord word;

  String get _statusLabel {
    final lastReviewedAt = word.lastReviewedAt;
    if (lastReviewedAt == null) return 'Yeni kelime';

    final days = DateTime.now().difference(lastReviewedAt).inDays;
    return days >= 3 ? 'Uzun süredir görülmedi' : 'Tekrar zamanı';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppBadge(
                label: _statusLabel,
                variant: AppBadgeVariant.primary,
                icon: const Icon(Icons.schedule_rounded),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      word.word,
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                    if (word.sentenceBlank.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        word.sentenceBlank,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const _DeckCardHint(
            icon: Icons.touch_app_rounded,
            label: 'Anlamı görmek için dokun',
          ),
        ],
      ),
    );
  }
}

class _DeckCardBack extends StatelessWidget {
  const _DeckCardBack({required this.word});

  final DeckWord word;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppBadge(
                label: 'ÇEVİRİ',
                variant: AppBadgeVariant.primary,
                icon: Icon(Icons.translate_rounded),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      word.translation.isEmpty
                          ? 'Çeviri bulunamadı'
                          : word.translation,
                      textAlign: TextAlign.center,
                      style: AppTypography.headingMedium.copyWith(
                        color: AppColors.foreground,
                      ),
                    ),
                    if (word.exampleSentence.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text.rich(
                        _sentenceSpan(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const _DeckCardHint(
            icon: Icons.replay_rounded,
            label: 'Kelimeye dönmek için dokun',
          ),
        ],
      ),
    );
  }

  TextSpan _sentenceSpan() {
    final style = AppTypography.bodyMedium.copyWith(
      color: AppColors.secondaryForeground,
    );
    final sentence = word.exampleSentence;
    final index = word.word.isEmpty
        ? -1
        : sentence.toLowerCase().indexOf(word.word.toLowerCase());
    if (index < 0) return TextSpan(text: sentence, style: style);

    final end = index + word.word.length;

    return TextSpan(
      style: style,
      children: [
        TextSpan(text: sentence.substring(0, index)),
        TextSpan(
          text: sentence.substring(index, end),
          style: style.copyWith(
            color: AppColors.primaryGlow,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextSpan(text: sentence.substring(end)),
      ],
    );
  }
}

class _DeckCardHint extends StatelessWidget {
  const _DeckCardHint({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSpacing.lg, color: AppColors.mutedForeground),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}
