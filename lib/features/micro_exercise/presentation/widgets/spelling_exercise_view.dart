import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/exercise_item.dart';
import '../cubit/exercise_state.dart';

class SpellingExerciseView extends StatefulWidget {
  const SpellingExerciseView({
    super.key,
    required this.item,
    required this.answer,
    required this.onSubmit,
  });

  final SpellingExercise item;
  final ExerciseAnswer? answer;
  final ValueChanged<String> onSubmit;

  @override
  State<SpellingExerciseView> createState() => _SpellingExerciseViewState();
}

class _SpellingExerciseViewState extends State<SpellingExerciseView> {
  final List<int> _enteredKeys = <int>[];

  String get _word => widget.item.word;

  String get _masked =>
      '${_word[0]}${'_' * (_word.length - 2)}${_word[_word.length - 1]}';

  int get _missingCount => _word.length - 2;

  bool get _isComplete => _enteredKeys.length == _missingCount;

  String get _typed =>
      _enteredKeys.map((index) => widget.item.letters[index]).join();

  String get _typedWord => '${_word[0]}$_typed${_word[_word.length - 1]}';

  void _tapKey(int index) {
    if (widget.answer != null ||
        _enteredKeys.contains(index) ||
        _enteredKeys.length >= _missingCount) {
      return;
    }
    setState(() => _enteredKeys.add(index));
  }

  void _undo() {
    if (widget.answer != null || _enteredKeys.isEmpty) return;
    setState(() => _enteredKeys.removeLast());
  }

  void _submit() {
    if (widget.answer != null || !_isComplete) return;
    widget.onSubmit(_typedWord);
  }

  @override
  Widget build(BuildContext context) {
    final sentenceStyle = AppTypography.headingSmall.copyWith(
      color: AppColors.foreground,
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eksik harfleri tamamla.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl + AppSpacing.xs),
        if (widget.item.sentence.isNotEmpty)
          HighlightedText(
            text: widget.item.sentence,
            highlight: _masked,
            style: sentenceStyle,
            highlightStyle: sentenceStyle.copyWith(
              color: AppColors.primaryGlow,
            ),
          )
        else
          Text(
            _masked,
            style: sentenceStyle.copyWith(color: AppColors.primaryGlow),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(
          widget.item.translation,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _letterBox(_word[0], isBlank: false),
            for (var index = 0; index < _missingCount; index++)
              _letterBox(
                index < _enteredKeys.length
                    ? widget.item.letters[_enteredKeys[index]]
                    : '·',
                isBlank: true,
                isFilled: index < _enteredKeys.length,
              ),
            _letterBox(_word[_word.length - 1], isBlank: false),
          ],
        ),
        if (widget.answer != null && !widget.answer!.isCorrect) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Doğru cevap: $_word',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxxl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var index = 0; index < widget.item.letters.length; index++)
              _letterKey(index),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Tooltip(
          message: 'Son harfi geri al',
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: widget.answer == null && _enteredKeys.isNotEmpty
                  ? _undo
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mutedForeground,
                minimumSize: const Size.fromHeight(
                  AppSpacing.xxxl + AppSpacing.xs,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              ),
              child: const Icon(Icons.rotate_left_rounded),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Kontrol et',
          expanded: true,
          onPressed: widget.answer == null && _isComplete ? _submit : null,
        ),
      ],
    );
  }

  Widget _letterBox(
    String label, {
    required bool isBlank,
    bool isFilled = false,
  }) {
    final answer = widget.answer;
    final Color background;
    final BorderSide border;
    final Color foreground;

    if (!isBlank) {
      background = AppColors.secondary;
      border = AppBorders.side;
      foreground = AppColors.secondaryForeground;
    } else if (answer == null) {
      background = AppColors.primarySoft;
      border = AppBorders.sidePrimary;
      foreground = isFilled ? AppColors.primaryGlow : AppColors.mutedForeground;
    } else if (answer.isCorrect) {
      background = AppColors.successSoft;
      border = AppBorders.sideSuccess;
      foreground = AppColors.success;
    } else {
      background = AppColors.destructiveSoft;
      border = AppBorders.sideDestructive;
      foreground = AppColors.destructive;
    }

    return Container(
      width: AppSpacing.huge + AppSpacing.xs,
      height: AppSpacing.huge + AppSpacing.lg,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.lgAll,
        border: Border.fromBorderSide(border),
      ),
      child: Text(
        label,
        style: AppTypography.headingSmall.copyWith(color: foreground),
      ),
    );
  }

  Widget _letterKey(int index) {
    final disabled = widget.answer != null || _enteredKeys.contains(index);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: disabled ? 0.35 : 1,
      child: SizedBox(
        width: AppSpacing.giant,
        height: AppSpacing.giant,
        child: Material(
          color: AppColors.secondary,
          clipBehavior: Clip.antiAlias,
          borderRadius: AppRadius.mdAll,
          child: InkWell(
            onTap: disabled ? null : () => _tapKey(index),
            overlayColor: const WidgetStatePropertyAll(
              AppColors.foregroundFaint,
            ),
            child: Center(
              child: Text(
                widget.item.letters[index],
                style: AppTypography.titleLarge.copyWith(
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
