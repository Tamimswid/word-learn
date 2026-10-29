import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Base surface for pages: two brand-colored glows drifting slowly behind
/// [child]. Circles are painted only, so page content never rebuilds.
class AppAnimatedBackground extends StatefulWidget {
  const AppAnimatedBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AppAnimatedBackground> createState() => _AppAnimatedBackgroundState();
}

class _AppAnimatedBackgroundState extends State<AppAnimatedBackground> with SingleTickerProviderStateMixin {
  static const Duration _cycle = Duration(seconds: 24);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycle)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.background),
        IgnorePointer(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(painter: _GlowPainter(_controller.value)),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _GlowPainter extends CustomPainter {
  const _GlowPainter(this.progress);

  final double progress;

  /// Circle diameter relative to the screen's shorter side.
  static const double _diameterRatio = 0.8 * 1.3;

  /// Peak opacity at the circle center.
  static const double _opacity = 0.2;

  /// Orbit half-axes relative to the screen; circles leave every edge.
  static const double _orbitWidthRatio = 0.55;
  static const double _orbitHeightRatio = 0.45;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final radius = size.shortestSide * _diameterRatio / 2;
    final orbitCenter = Offset(size.width * 0.5, size.height * 0.48);
    final orbit = Offset(size.width * _orbitWidthRatio, size.height * _orbitHeightRatio);
    final angle = progress * 2 * math.pi;

    _paintGlow(
      canvas,
      center: orbitCenter + _onOrbit(orbit, angle),
      radius: radius,
      color: AppColors.primary.withValues(alpha: 0.2),
    );
    _paintGlow(
      canvas,
      // Half a lap apart: the second glow mirrors every axis of the first.
      center: orbitCenter + _onOrbit(orbit, angle + math.pi),
      radius: radius,
      color: AppColors.primary.withValues(alpha: 0.2),
    );
  }

  /// Elliptical path that leaves and re-enters the screen on every lap.
  Offset _onOrbit(Offset orbit, double angle) {
    return Offset(math.cos(angle) * orbit.dx, math.sin(angle) * orbit.dy);
  }

  void _paintGlow(Canvas canvas, {required Offset center, required double radius, required Color color}) {
    final shader = RadialGradient(
      colors: [
        color.withValues(alpha: _opacity),
        color.withValues(alpha: _opacity * 0.35),
        AppColors.transparent,
      ],
      stops: const [0, 0.55, 1],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) => oldDelegate.progress != progress;
}
