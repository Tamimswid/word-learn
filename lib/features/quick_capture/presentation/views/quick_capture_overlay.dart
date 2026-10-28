import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../cubit/quick_capture_cubit.dart';
import '../cubit/quick_capture_state.dart';

/// Root widget used while the capture overlay is visible in the app window.
class QuickCaptureOverlayApp extends StatelessWidget {
  const QuickCaptureOverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuickCaptureCubit>.value(
      value: locator<QuickCaptureCubit>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        color: AppColors.transparent,
        theme: AppTheme.dark,
        home: const QuickCaptureOverlay(),
      ),
    );
  }
}

class QuickCaptureOverlay extends StatelessWidget {
  const QuickCaptureOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuickCaptureCubit, QuickCaptureState>(
      builder: (context, state) {
        return Material(
          type: MaterialType.transparency,
          child: SizedBox.expand(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: AppRadius.xlAll,
                border: Border.fromBorderSide(AppBorders.sideStrong),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: KeyedSubtree(
                      key: ValueKey(state.status),
                      child: _content(state),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content(QuickCaptureState state) {
    if (state.isSuccess) {
      return _Success(
        word: state.word?.word ?? '',
        translation: state.word?.translation ?? '',
      );
    }
    if (state.isFailure) return const _Failure();
    return const _Loading();
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 40,
      child: Center(child: _OrbSpinner()),
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({required this.word, required this.translation});

  final String word;
  final String translation;

  @override
  Widget build(BuildContext context) {
    final primary = translation.isEmpty ? word : translation;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.72, end: 1),
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(AppBorders.sideSuccess),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 22,
              color: AppColors.success,
            ),
          ),
        ),
        if (primary.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (translation.isNotEmpty)
                  Text(
                    word,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                Text(
                  primary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.destructiveSoft,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(AppBorders.sideDestructive),
      ),
      child: const Icon(
        Icons.error_outline_rounded,
        size: 22,
        color: AppColors.destructive,
      ),
    );
  }
}

class _OrbSpinner extends StatefulWidget {
  const _OrbSpinner();

  @override
  State<_OrbSpinner> createState() => _OrbSpinnerState();
}

class _OrbSpinnerState extends State<_OrbSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) =>
            CustomPaint(painter: _OrbPainter(turn: _controller.value)),
      ),
    );
  }
}

/// A small glossy sphere with an orbiting ring, drawn in the brand color.
class _OrbPainter extends CustomPainter {
  const _OrbPainter({required this.turn});

  final double turn;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final angle = turn * math.pi * 2;

    canvas.drawCircle(center, radius, Paint()..color = AppColors.primarySoft);

    final orbit = Rect.fromCenter(
      center: Offset.zero,
      width: radius * 1.9,
      height: radius * 0.72,
    );
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [AppColors.transparent, AppColors.primaryGlow],
      ).createShader(orbit);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(orbit, orbitPaint);
    canvas.restore();

    final sphereRadius = radius * 0.55;
    final sphere = Rect.fromCircle(center: center, radius: sphereRadius);
    canvas.drawCircle(
      center,
      sphereRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.45),
          radius: 0.95,
          colors: [
            AppColors.primaryGlow,
            AppColors.primary,
            Color.lerp(AppColors.primary, AppColors.canvas, 0.55)!,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(sphere),
    );

    canvas.drawCircle(
      center + Offset(-sphereRadius * 0.32, -sphereRadius * 0.38),
      sphereRadius * 0.16,
      Paint()..color = AppColors.onPrimary.withValues(alpha: 0.32),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter oldDelegate) => oldDelegate.turn != turn;
}
