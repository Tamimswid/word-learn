import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/exercise_item.dart';
import '../cubit/exercise_state.dart';

class SentenceExerciseView extends StatefulWidget {
  const SentenceExerciseView({
    super.key,
    required this.item,
    required this.answer,
    required this.onSubmit,
  });

  final SentenceExercise item;
  final ExerciseAnswer? answer;
  final ValueChanged<List<String>> onSubmit;

  @override
  State<SentenceExerciseView> createState() => _SentenceExerciseViewState();
}

class _SentenceExerciseViewState extends State<SentenceExerciseView> {
  final List<int> _selected = <int>[];

  bool get _isComplete => _selected.length == widget.item.tokens.length;

  void _pick(int index) {
    if (widget.answer != null || _selected.contains(index)) return;
    setState(() => _selected.add(index));
  }

  void _unpick(int index) {
    if (widget.answer != null) return;
    setState(() => _selected.remove(index));
  }

  void _submit() {
    if (widget.answer != null || !_isComplete) return;
    widget.onSubmit(
      _selected.map((index) => widget.item.tokens[index]).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final answer = widget.answer;
    final borderColor = answer == null
        ? AppColors.border
        : answer.isCorrect
        ? AppColors.successBorder
        : AppColors.destructiveBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İngilizce cümleyi oluştur.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl + AppSpacing.xs),
        Text(
          '“${widget.item.translation}” anlamındaki cümleyi kur.',
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl + AppSpacing.xs),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: AppSpacing.huge * 2 + AppSpacing.xxxl,
          ),
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: borderColor, width: AppBorders.width),
            ),
          ),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final index in _selected)
                _TokenChip(
                  label: widget.item.tokens[index],
                  onTap: () => _unpick(index),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var index = 0; index < widget.item.tokens.length; index++)
              if (!_selected.contains(index))
                _TokenChip(
                  label: widget.item.tokens[index],
                  onTap: widget.answer == null ? () => _pick(index) : null,
                ),
          ],
        ),
        if (answer != null && !answer.isCorrect) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Doğru cümle: ${widget.item.correctSentence}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxxl),
        AppButton(
          label: 'Kontrol et',
          expanded: true,
          onPressed: widget.answer == null && _isComplete ? _submit : null,
        ),
      ],
    );
  }
}

class _TokenChip extends StatelessWidget {
  const _TokenChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.huge + AppSpacing.xs,
      child: Material(
        color: AppColors.secondary,
        clipBehavior: Clip.antiAlias,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: onTap,
          overlayColor: const WidgetStatePropertyAll(AppColors.foregroundFaint),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
