import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';

Future<bool> showDeleteWordDialog(BuildContext context, String word) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => DeleteWordDialog(word: word),
  );

  return confirmed ?? false;
}

class DeleteWordDialog extends StatelessWidget {
  const DeleteWordDialog({super.key, required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Kelimeyi sil',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '"$word" kelimesini silmek istediğine emin misin?',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Vazgeç',
                    variant: AppButtonVariant.secondary,
                    expanded: true,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                Expanded(
                  child: AppButton(
                    label: 'Sil',
                    variant: AppButtonVariant.danger,
                    expanded: true,
                    onPressed: () => Navigator.of(context).pop(true),
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
