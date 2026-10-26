import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';

class SessionSizeSection extends StatelessWidget {
  const SessionSizeSection({
    super.key,
    required this.selected,
    required this.isCustom,
    required this.customController,
    required this.invalid,
    required this.onSelectPreset,
    required this.onSelectCustom,
    required this.onCustomChanged,
    required this.onCustomSubmitted,
  });

  static const List<int> presets = <int>[5, 10, 20];
  static const int minWords = 5;
  static const int maxWords = 50;

  final int selected;
  final bool isCustom;
  final TextEditingController customController;
  final bool invalid;
  final ValueChanged<int> onSelectPreset;
  final VoidCallback onSelectCustom;
  final ValueChanged<String> onCustomChanged;
  final ValueChanged<String> onCustomSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionHeader(
          title: 'Oturum başına kelime',
          description: 'Her oturumda göreceğin kelime sayısını seç.',
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          spacing: AppSpacing.sm,
          children: [
            for (final value in presets)
              _SizeOption(
                label: '$value',
                isSelected: !isCustom && selected == value,
                onTap: () => onSelectPreset(value),
              ),
            _SizeOption(
              label: 'Özel',
              isSelected: isCustom,
              onTap: onSelectCustom,
            ),
          ],
        ),
        if (isCustom) ...[
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: customController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '$minWords–$maxWords',
              errorText: invalid
                  ? '$minWords ile $maxWords arasında bir sayı gir.'
                  : null,
            ),
            onChanged: onCustomChanged,
            onSubmitted: onCustomSubmitted,
          ),
        ],
      ],
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        child: Material(
          color: isSelected ? AppColors.primarySoft : AppColors.transparent,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            overlayColor: const WidgetStatePropertyAll(
              AppColors.foregroundFaint,
            ),
            child: SizedBox(
              height: AppSpacing.huge,
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected
                        ? AppColors.primaryGlow
                        : AppColors.secondaryForeground,
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
