import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/word_entry.dart';
import '../cubit/add_word_cubit.dart';
import '../cubit/add_word_state.dart';

Future<WordEntry?> showAddWordDialog(
  BuildContext context, {
  String? initialWord,
}) {
  return showDialog<WordEntry>(
    context: context,
    builder: (context) => BlocProvider<AddWordCubit>(
      create: (_) => locator<AddWordCubit>(),
      child: AddWordDialog(initialWord: initialWord),
    ),
  );
}

class AddWordDialog extends StatefulWidget {
  const AddWordDialog({super.key, this.initialWord});

  final String? initialWord;

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();

  String? _wordError;

  @override
  void initState() {
    super.initState();
    final initialWord = widget.initialWord;
    if (initialWord == null || initialWord.isEmpty) return;

    _wordController.value = TextEditingValue(
      text: initialWord,
      selection: TextSelection.collapsed(offset: initialWord.length),
    );
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddWordCubit, AddWordState>(
      builder: (context, state) {
        return Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Kelime ekle',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Kelimeyi gir; anlamını istersen kendin yazabilirsin.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _wordController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isLoading,
                  onChanged: (_) => _clearErrors(context),
                  decoration: InputDecoration(
                    labelText: 'Kelime',
                    hintText: 'örn. brave',
                    errorText: _wordError,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _translationController,
                  textInputAction: TextInputAction.done,
                  enabled: !state.isLoading,
                  onChanged: (_) => _clearErrors(context),
                  onSubmitted: (_) => _submit(context),
                  decoration: const InputDecoration(
                    labelText: 'Anlamı (isteğe bağlı)',
                    hintText: 'örn. cesur',
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
                        onPressed: state.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    Expanded(
                      child: AppButton(
                        label: 'Ekle',
                        expanded: true,
                        isLoading: state.isLoading,
                        onPressed: state.isLoading
                            ? null
                            : () => _submit(context),
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

  void _clearErrors(BuildContext context) {
    if (_wordError != null) {
      setState(() => _wordError = null);
    }
    context.read<AddWordCubit>().clearError();
  }

  Future<void> _submit(BuildContext context) async {
    final word = _wordController.text.trim();
    final translation = _translationController.text.trim();

    if (word.isEmpty) {
      setState(() => _wordError = 'Kelime gerekli.');
      return;
    }

    final entry = await context.read<AddWordCubit>().add(
      word,
      translation: translation.isEmpty ? null : translation,
    );

    if (!context.mounted || entry == null) return;

    Navigator.of(context).pop(entry);
  }
}
