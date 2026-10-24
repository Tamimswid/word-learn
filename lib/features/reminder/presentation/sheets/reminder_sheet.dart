import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/reminder_cubit.dart';
import '../cubit/reminder_state.dart';

Future<bool?> showReminderSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => BlocProvider<ReminderCubit>(
      create: (_) => locator<ReminderCubit>()..load(),
      child: const ReminderSheet(),
    ),
  );
}

class ReminderSheet extends StatelessWidget {
  const ReminderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReminderCubit, ReminderState>(
      listenWhen: (previous, current) => current.isSaved && !previous.isSaved,
      listener: (context, state) => Navigator.of(context).pop(true),
      child: BlocBuilder<ReminderCubit, ReminderState>(
        builder: (context, state) {
          if (!state.hasLoaded) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.giant),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _ReminderForm(state: state);
        },
      ),
    );
  }
}

class _ReminderForm extends StatelessWidget {
  const _ReminderForm({required this.state});

  final ReminderState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReminderCubit>();
    final settings = state.settings;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sheet,
        0,
        AppSpacing.sheet,
        AppSpacing.sheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Günlük hatırlatıcı',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.secondaryForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Seçtiğin saat aralığında bugünün kelimeleri sırayla hatırlatılır.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _ToggleRow(
            isEnabled: settings.isEnabled,
            onChanged: cubit.setEnabled,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                child: _TimeField(
                  label: 'Başlangıç',
                  minutes: settings.startMinutes,
                  onTap: () => _pickTime(
                    context,
                    label: 'Başlangıç',
                    minutes: settings.startMinutes,
                    onPicked: cubit.setStartMinutes,
                  ),
                ),
              ),
              Expanded(
                child: _TimeField(
                  label: 'Bitiş',
                  minutes: settings.endMinutes,
                  onTap: () => _pickTime(
                    context,
                    label: 'Bitiş',
                    minutes: settings.endMinutes,
                    onPicked: cubit.setEndMinutes,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Kelimeler arasında 10 dk – 2 saat rastgele aralık bırakılır.',
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          if (!settings.isValid) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bitiş saati başlangıçtan sonra olmalı.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.destructive,
              ),
            ),
          ],
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.errorMessage!,
              style: AppTypography.bodySmall.copyWith(
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
                  label: 'Kaydet',
                  expanded: true,
                  isLoading: state.isLoading,
                  onPressed: state.isLoading || !settings.isValid
                      ? null
                      : cubit.save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context, {
    required String label,
    required int minutes,
    required ValueChanged<int> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      helpText: '$label saati',
      cancelText: 'Vazgeç',
      confirmText: 'Tamam',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    onPicked(picked.hour * 60 + picked.minute);
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.isEnabled, required this.onChanged});

  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            size: AppSpacing.xl,
            color: AppColors.primaryGlow,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hatırlatıcıyı aç',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Gün içinde kelime tekrarı',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.minutes,
    required this.onTap,
  });

  final String label;
  final int minutes;
  final VoidCallback onTap;

  String get _value {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final minute = (minutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label saati $_value',
      child: Material(
        color: AppColors.secondary,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          overlayColor: const WidgetStatePropertyAll(
            AppColors.foregroundFaint,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _value,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
