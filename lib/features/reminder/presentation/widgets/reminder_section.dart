import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/reminder_state.dart';

class ReminderSection extends StatelessWidget {
  const ReminderSection({
    super.key,
    required this.state,
    required this.onEnabledChanged,
    required this.onStartMinutesChanged,
    required this.onEndMinutesChanged,
  });

  final ReminderState state;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onStartMinutesChanged;
  final ValueChanged<int> onEndMinutesChanged;

  @override
  Widget build(BuildContext context) {
    final settings = state.settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionHeader(
          title: 'Günlük hatırlatıcı',
          description:
              'Seçtiğin saat aralığında bugünün kelimeleri sırayla hatırlatılır.',
        ),
        const SizedBox(height: AppSpacing.lg),
        _ReminderToggle(
          isEnabled: settings.isEnabled,
          onChanged: onEnabledChanged,
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
                  onPicked: onStartMinutesChanged,
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
                  onPicked: onEndMinutesChanged,
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
          const _ErrorText('Bitiş saati başlangıçtan sonra olmalı.'),
        ],
        if (state.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _ErrorText(state.errorMessage!),
        ],
      ],
    );
  }
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
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
  );
  if (picked == null) return;

  onPicked(picked.hour * 60 + picked.minute);
}

class _ReminderToggle extends StatelessWidget {
  const _ReminderToggle({required this.isEnabled, required this.onChanged});

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
          Switch.adaptive(value: isEnabled, onChanged: onChanged),
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
          overlayColor: const WidgetStatePropertyAll(AppColors.foregroundFaint),
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

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: AppTypography.bodySmall.copyWith(color: AppColors.destructive),
    );
  }
}
