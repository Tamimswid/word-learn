import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../data/models/home_snapshot.dart';

/// Bar chart fed by plain [ActivityPoint]s so a backend can map its rows
/// straight into it without touching the rendering code.
class ActivityBarChart extends StatelessWidget {
  const ActivityBarChart({super.key, required this.points});

  final List<ActivityPoint> points;

  static const double _chartHeight = AppSpacing.giant * 2;
  static const double _minBarHeight = AppSpacing.xs;
  static const Duration _animationDuration = Duration(milliseconds: 650);

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<double>(
      0,
      (current, point) => point.value > current ? point.value : current,
    );
    final scale = maxValue <= 0 ? 1.0 : maxValue;
    final minFactor = _minBarHeight / _chartHeight;

    return Semantics(
      label: 'Öğrenme grafiği',
      child: ExcludeSemantics(
        child: Column(
          children: [
            Container(
              height: _chartHeight,
              decoration: const BoxDecoration(border: AppBorders.bottom),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: AppSpacing.sm,
                children: [
                  for (final point in points)
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: point.value),
                        duration: _animationDuration,
                        curve: Curves.easeOutCubic,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: point.isCurrent
                                ? AppColors.primaryGlow
                                : AppColors.primaryBar,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppRadius.xs),
                            ),
                          ),
                        ),
                        builder: (context, value, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.bottomCenter,
                            heightFactor: (value / scale)
                                .clamp(minFactor, 1.0)
                                .toDouble(),
                            child: child,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              spacing: AppSpacing.sm,
              children: [
                for (final point in points)
                  Expanded(
                    child: Text(
                      point.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.overline.copyWith(
                        color: point.isCurrent
                            ? AppColors.primaryGlow
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
