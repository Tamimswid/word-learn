import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/home_snapshot.dart';
import 'activity_bar_chart.dart';

enum _ActivityPeriod { weekly, monthly }

const Duration _numberAnimation = Duration(milliseconds: 650);

class LearningRhythmCard extends StatefulWidget {
  const LearningRhythmCard({super.key, required this.snapshot});

  final HomeSnapshot snapshot;

  @override
  State<LearningRhythmCard> createState() => _LearningRhythmCardState();
}

class _LearningRhythmCardState extends State<LearningRhythmCard> {
  _ActivityPeriod _period = _ActivityPeriod.weekly;

  List<ActivityPoint> get _points => _period == _ActivityPeriod.weekly
      ? widget.snapshot.weeklyPoints
      : widget.snapshot.monthlyPoints;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Öğrenme ritmin',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ),
              _PeriodToggle(period: _period, onChanged: _selectPeriod),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: widget.snapshot.learnedCount.toDouble(),
                      ),
                      duration: _numberAnimation,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Text(
                        '${value.round()}',
                        style: AppTypography.headingLarge.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        'kelime öğrenildi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: widget.snapshot.changePercent.toDouble(),
                ),
                duration: _numberAnimation,
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  final percent = value.round();
                  return Text(
                    '${percent < 0 ? '-' : '+'}%${percent.abs()}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ActivityBarChart(points: _points),
        ],
      ),
    );
  }

  void _selectPeriod(_ActivityPeriod period) {
    if (period == _period) return;
    setState(() => _period = period);
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.period, required this.onChanged});

  final _ActivityPeriod period;
  final ValueChanged<_ActivityPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xxs,
        children: [
          _option('Haftalık', _ActivityPeriod.weekly),
          _option('Aylık', _ActivityPeriod.monthly),
        ],
      ),
    );
  }

  Widget _option(String label, _ActivityPeriod value) {
    final isSelected = period == value;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.card : AppColors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: () => onChanged(value),
          child: SizedBox(
            height: AppSpacing.xxl,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Center(
                child: Text(
                  label,
                  style: AppTypography.overline.copyWith(
                    color: isSelected
                        ? AppColors.foreground
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
