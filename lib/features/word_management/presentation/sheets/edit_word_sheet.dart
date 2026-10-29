import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/word_summary.dart';
import '../cubit/edit_word_cubit.dart';
import '../cubit/edit_word_state.dart';

Future<WordSummary?> showEditWordSheet(
  BuildContext context, {
  required WordSummary word,
}) {
  return showModalBottomSheet<WordSummary>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => BlocProvider<EditWordCubit>(
      create: (_) => locator<EditWordCubit>(),
      child: EditWordSheet(word: word),
    ),
  );
}

class EditWordSheet extends StatefulWidget {
  const EditWordSheet({super.key, required this.word});

  final WordSummary word;

  @override
  State<EditWordSheet> createState() => _EditWordSheetState();
}

class _EditWordSheetState extends State<EditWordSheet> {
  late final TextEditingController _wordController;
  late final TextEditingController _translationController;
  late final TextEditingController _exampleController;
  late final TextEditingController _arabicController;

  String? _wordError;
  String? _translationError;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.word.word);
    _translationController = TextEditingController(
      text: widget.word.translation,
    );
    _exampleController = TextEditingController(
      text: widget.word.exampleSentence,
    );
    _arabicController = TextEditingController(text: widget.word.arabicSentence);
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _exampleController.dispose();
    _arabicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditWordCubit, EditWordState>(
      builder: (context, state) {
        final canSave = !state.isSaving && _isValid && _hasChanges;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sheet,
            0,
            AppSpacing.sheet,
            AppSpacing.sheet,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Kelimeyi düzenle',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Kelimeyi, anlamını ve cümleleri buradan güncelleyebilirsin.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _wordController,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isSaving,
                  onChanged: (_) => _handleChanged(context),
                  decoration: InputDecoration(
                    labelText: 'Kelime',
                    hintText: 'örn. brave',
                    errorText: _wordError,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _translationController,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isSaving,
                  onChanged: (_) => _handleChanged(context),
                  decoration: InputDecoration(
                    labelText: 'Anlamı',
                    hintText: 'örn. cesur',
                    errorText: _translationError,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _exampleController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 2,
                  maxLines: 4,
                  enabled: !state.isSaving,
                  onChanged: (_) => _handleChanged(context),
                  decoration: const InputDecoration(
                    labelText: 'Örnek cümle',
                    hintText: 'Kelimenin geçtiği cümle',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _arabicController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 2,
                  maxLines: 4,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  enabled: !state.isSaving,
                  onChanged: (_) => _handleChanged(context),
                  decoration: const InputDecoration(
                    labelText: 'Arapça cümle',
                    hintText: 'Cümlenin Arapça karşılığı',
                    alignLabelWithHint: true,
                  ),
                ),
                if (state.failure != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    state.failure!.message,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.destructive,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  spacing: AppSpacing.sm,
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Vazgeç',
                        variant: AppButtonVariant.secondary,
                        expanded: true,
                        onPressed: state.isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    Expanded(
                      child: AppButton(
                        label: 'Kaydet',
                        expanded: true,
                        isLoading: state.isSaving,
                        onPressed: canSave ? () => _submit(context) : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _isValid =>
      _wordController.text.trim().isNotEmpty &&
      _translationController.text.trim().isNotEmpty;

  bool get _hasChanges {
    final current = widget.word;

    return _wordController.text.trim() != current.word ||
        _translationController.text.trim() != current.translation ||
        _exampleController.text.trim() != current.exampleSentence ||
        _arabicController.text.trim() != current.arabicSentence;
  }

  void _handleChanged(BuildContext context) {
    setState(() {
      _wordError = null;
      _translationError = null;
    });
    context.read<EditWordCubit>().clearError();
  }

  Future<void> _submit(BuildContext context) async {
    final word = _wordController.text.trim();
    final translation = _translationController.text.trim();

    setState(() {
      _wordError = word.isEmpty ? 'Kelime gerekli.' : null;
      _translationError = translation.isEmpty ? 'Anlamı gerekli.' : null;
    });

    if (word.isEmpty || translation.isEmpty) return;

    final updated = await context.read<EditWordCubit>().save(
      widget.word,
      word: word,
      translation: translation,
      exampleSentence: _exampleController.text.trim(),
      arabicSentence: _arabicController.text.trim(),
    );

    if (!context.mounted || updated == null) return;

    Navigator.of(context).pop(updated);
  }
}
