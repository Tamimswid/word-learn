import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../models/word_preview.dart';

/// Tunable timings and geometry for [AuthWordCards].
@immutable
class AuthWordCardsConfig {
  const AuthWordCardsConfig({
    this.autoAdvance = const Duration(milliseconds: 1300),
    this.transition = const Duration(milliseconds: 520),
    this.interactionPause = const Duration(seconds: 6),
    this.curve = Curves.easeOutCubic,
    this.tiltDegrees = 7,
    this.backOffset = const Offset(0.16, 0.06),
    this.backScale = 0.92,
    this.backOpacity = 0.55,
    this.maxCardWidth = 320,
    this.cardAspectRatio = 0.82,
  });

  /// Delay between automatic steps.
  final Duration autoAdvance;

  /// Duration of the slide, tilt and fade between slots.
  final Duration transition;

  /// How long the deck stays still after the user taps a card.
  final Duration interactionPause;
  final Curve curve;

  /// Tilt applied to both background cards, in opposite directions.
  final double tiltDegrees;

  /// Background card shift as a fraction of the card size.
  final Offset backOffset;
  final double backScale;
  final double backOpacity;
  final double maxCardWidth;

  /// Card width divided by height; below 1 the cards are taller than wide.
  final double cardAspectRatio;

  double get tiltTurns => tiltDegrees / 360;
}

/// Three preview cards arranged as a deck: one in front, two tilted behind.
///
/// The deck cycles on its own. Tapping the front or right-hand card moves
/// forward, tapping the left-hand card moves back, and any tap pauses the
/// automatic rotation for [AuthWordCardsConfig.interactionPause].
class AuthWordCards extends StatefulWidget {
  const AuthWordCards({
    super.key,
    this.deck = wordPreviewDeck,
    this.config = const AuthWordCardsConfig(),
  });

  final List<WordPreview> deck;
  final AuthWordCardsConfig config;

  @override
  State<AuthWordCards> createState() => _AuthWordCardsState();
}

class _AuthWordCardsState extends State<AuthWordCards> {
  static const int _frontSlot = 0;
  static const int _rightSlot = 1;
  static const int _leftSlot = 2;

  int _front = 0;
  Timer? _timer;
  bool _reduceMotion = false;
  bool _dependenciesReady = false;

  AuthWordCardsConfig get _config => widget.config;

  @override
  void initState() {
    super.initState();
    assert(widget.deck.length == 3, 'AuthWordCards is designed for three cards.');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_dependenciesReady && reduceMotion == _reduceMotion) return;

    _dependenciesReady = true;
    _reduceMotion = reduceMotion;
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoAdvance() {
    _timer?.cancel();
    if (_reduceMotion) return;

    _timer = Timer.periodic(_config.autoAdvance, (_) => _step(1));
  }

  void _handleTap(int slot) {
    _step(slot == _leftSlot ? -1 : 1);

    // Linger on the chosen card before the deck starts moving again.
    _timer?.cancel();
    if (_reduceMotion) return;

    _timer = Timer(_config.interactionPause, _startAutoAdvance);
  }

  void _step(int delta) {
    setState(() => _front = (_front + delta) % widget.deck.length);
  }

  int _slotOf(int index) => (index - _front) % widget.deck.length;

  _CardSlot _slotFor(int index) {
    final slot = _slotOf(index);
    if (slot == _frontSlot) {
      return const _CardSlot(
        offset: Offset.zero,
        turns: 0,
        scale: 1,
        opacity: 1,
        depth: 2,
      );
    }

    final mirrored = slot != _rightSlot;
    return _CardSlot(
      offset: Offset(
        mirrored ? -_config.backOffset.dx : _config.backOffset.dx,
        _config.backOffset.dy,
      ),
      turns: mirrored ? -_config.tiltTurns : _config.tiltTurns,
      scale: _config.backScale,
      opacity: _config.backOpacity,
      depth: mirrored ? 0 : 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final duration = _reduceMotion ? Duration.zero : _config.transition;
    final slots = <_CardSlot>[
      for (var index = 0; index < widget.deck.length; index++) _slotFor(index),
    ];
    final paintOrder = <int>[
      for (var index = 0; index < slots.length; index++) index,
    ]..sort((a, b) => slots[a].depth.compareTo(slots[b].depth));

    return LayoutBuilder(
      builder: (context, constraints) {
        var width = math.min(
          _config.maxCardWidth,
          constraints.hasBoundedWidth
              ? constraints.maxWidth
              : _config.maxCardWidth,
        );
        var height = width / _config.cardAspectRatio;

        // Keep the deck inside the space the page reserves for it.
        if (constraints.hasBoundedHeight && height > constraints.maxHeight) {
          height = constraints.maxHeight;
          width = height * _config.cardAspectRatio;
        }

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            for (final index in paintOrder)
              AnimatedSlide(
                key: ValueKey<int>(index),
                offset: slots[index].offset,
                duration: duration,
                curve: _config.curve,
                child: AnimatedScale(
                  scale: slots[index].scale,
                  duration: duration,
                  curve: _config.curve,
                  child: AnimatedRotation(
                    turns: slots[index].turns,
                    duration: duration,
                    curve: _config.curve,
                    child: AnimatedOpacity(
                      opacity: slots[index].opacity,
                      duration: duration,
                      curve: _config.curve,
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: _WordPreviewCard(
                          preview: widget.deck[index],
                          onTap: () => _handleTap(_slotOf(index)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CardSlot {
  const _CardSlot({
    required this.offset,
    required this.turns,
    required this.scale,
    required this.opacity,
    required this.depth,
  });

  final Offset offset;
  final double turns;
  final double scale;
  final double opacity;

  /// Paint order; higher values sit on top.
  final int depth;
}

class _WordPreviewCard extends StatelessWidget {
  const _WordPreviewCard({required this.preview, required this.onTap});

  final WordPreview preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = AppRadius.xlAll;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: borderRadius,
        border: Border.fromBorderSide(AppBorders.side),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: InkWell(
          onTap: onTap,
          overlayColor: const WidgetStatePropertyAll(AppColors.foregroundFaint),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preview.word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.headingMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  preview.sentence,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
