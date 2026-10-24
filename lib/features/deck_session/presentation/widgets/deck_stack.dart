import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../data/models/deck_word.dart';
import 'deck_card.dart';

/// The current card with a muted deck card peeking out behind it.
class DeckStack extends StatelessWidget {
  const DeckStack({super.key, required this.words, required this.onAnswer});

  /// Remaining words, starting with the current one.
  final List<DeckWord> words;

  /// Called with `true` when the word was known, `false` otherwise.
  final ValueChanged<bool> onAnswer;

  static const double _aspectRatio = 0.8;
  static const double _backdropInset = AppSpacing.xxxl + AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) return const SizedBox.shrink();
    final word = words.first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = math.max(
          0.0,
          constraints.maxHeight - _backdropInset,
        );
        final height = math.min(
          constraints.maxWidth / _aspectRatio,
          availableHeight,
        );
        final width = height * _aspectRatio;

        return Center(
          child: SizedBox(
            width: width,
            height: height + _backdropInset,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: _backdropInset,
                  left: _backdropInset,
                  right: _backdropInset,
                  height: height,
                  child: const _DeckBackdrop(),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: height,
                  child: _FrontCard(
                    key: ValueKey<String>(word.id),
                    word: word,
                    onAnswer: onAnswer,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DeckBackdrop extends StatelessWidget {
  const _DeckBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: AppRadius.xlAll,
        border: Border.fromBorderSide(AppBorders.side),
      ),
    );
  }
}

class _FrontCard extends StatefulWidget {
  const _FrontCard({
    super.key,
    required this.word,
    required this.onAnswer,
  });

  final DeckWord word;
  final ValueChanged<bool> onAnswer;

  @override
  State<_FrontCard> createState() => _FrontCardState();
}

class _FrontCardState extends State<_FrontCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  )..forward();

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enter,
      child: _SwipeableCard(
        word: widget.word,
        enabled: true,
        onAnswer: widget.onAnswer,
      ),
      builder: (context, child) {
        final entrance = Curves.easeOutCubic.transform(_enter.value);

        return Opacity(
          opacity: entrance,
          child: Transform.translate(
            offset: Offset(0, (1 - entrance) * AppSpacing.giant),
            child: Transform.scale(
              scale: 0.96 + 0.04 * entrance,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _SwipeableCard extends StatefulWidget {
  const _SwipeableCard({
    required this.word,
    required this.enabled,
    required this.onAnswer,
  });

  final DeckWord word;
  final bool enabled;
  final ValueChanged<bool> onAnswer;

  @override
  State<_SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<_SwipeableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );

  Offset _drag = Offset.zero;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  bool _exiting = false;

  bool get _isAnimating => _controller.isAnimating;

  Offset get _offset {
    if (!_isAnimating) return _drag;
    final t = Curves.easeOutCubic.transform(_controller.value);
    return Offset.lerp(_from, _to, t) ?? _drag;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    if (!widget.enabled || _exiting) return;

    _controller.stop();
    _drag = _offset;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _exiting) return;

    setState(() => _drag += details.delta);
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enabled || _exiting) return;

    final width = context.size?.width ?? MediaQuery.sizeOf(context).width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final threshold = width * 0.28;

    if (_drag.dx.abs() >= threshold) {
      _startExit(known: _drag.dx > 0);
    } else if (velocity.abs() >= 700) {
      _startExit(known: velocity > 0);
    } else {
      _startSnapBack();
    }
  }

  void _onDragCancel() {
    if (!widget.enabled || _exiting) return;
    _startSnapBack();
  }

  void _startSnapBack() {
    _from = _drag;
    _to = Offset.zero;
    _controller.duration = const Duration(milliseconds: 260);

    _controller.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() => _drag = Offset.zero);
    });
  }

  void _startExit({required bool known}) {
    _exiting = true;

    final width = context.size?.width ?? MediaQuery.sizeOf(context).width;
    final direction = known ? 1.0 : -1.0;

    _from = _drag;
    _to = Offset(direction * (width + AppSpacing.huge * 4), _drag.dy + 120);
    _controller.duration = const Duration(milliseconds: 220);

    _controller.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      widget.onAnswer(known);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final offset = _offset;
            final progress = width <= 0
                ? 0.0
                : (offset.dx / (width * 0.3)).clamp(-1.0, 1.0);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: widget.enabled ? _onDragStart : null,
              onHorizontalDragUpdate: widget.enabled ? _onDragUpdate : null,
              onHorizontalDragEnd: widget.enabled ? _onDragEnd : null,
              onHorizontalDragCancel: widget.enabled ? _onDragCancel : null,
              child: Transform.translate(
                offset: offset,
                child: Transform.rotate(
                  angle: progress * 0.12,
                  child: DeckCard(
                    word: widget.word,
                    interactive: widget.enabled,
                    dragProgress: widget.enabled ? progress : 0,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
