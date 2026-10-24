import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/widgets.dart';

Future<int?> showSessionSizeSheet(
  BuildContext context, {
  required int initialValue,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => SessionSizeSheet(initialValue: initialValue),
  );
}

class SessionSizeSheet extends StatefulWidget {
  const SessionSizeSheet({super.key, required this.initialValue});

  static const List<int> presets = <int>[5, 10, 20];
  static const int minWords = 5;
  static const int maxWords = 50;

  final int initialValue;

  @override
  State<SessionSizeSheet> createState() => _SessionSizeSheetState();
}

class _SessionSizeSheetState extends State<SessionSizeSheet> {
  late final TextEditingController _customController;
  late bool _isCustom;
  late int _selected;
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _isCustom = !SessionSizeSheet.presets.contains(widget.initialValue);
    _selected = _isCustom ? SessionSizeSheet.presets[1] : widget.initialValue;
    _customController = TextEditingController(
      text: _isCustom ? '${widget.initialValue}' : '',
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sheet,
        0,
        AppSpacing.sheet,
        AppSpacing.sheet,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Oturum başına kelime',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.secondaryForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Her oturumda göreceğin kelime sayısını seç.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              spacing: AppSpacing.sm,
              children: [
                for (final value in SessionSizeSheet.presets)
                  _option(
                    label: '$value',
                    isSelected: !_isCustom && _selected == value,
                    onTap: () => _selectPreset(value),
                  ),
                _option(
                  label: 'Özel',
                  isSelected: _isCustom,
                  onTap: _selectCustom,
                ),
              ],
            ),
            if (_isCustom) ...[
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _customController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText:
                      '${SessionSizeSheet.minWords}–${SessionSizeSheet.maxWords}',
                  errorText: _invalid
                      ? '${SessionSizeSheet.minWords} ile '
                            '${SessionSizeSheet.maxWords} arasında bir sayı gir.'
                      : null,
                ),
                onChanged: (_) {
                  if (_invalid) setState(() => _invalid = false);
                },
                onSubmitted: (_) => _save(),
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: AppButton(
                    label: 'Kaydet',
                    expanded: true,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _option({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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

  void _selectPreset(int value) {
    setState(() {
      _isCustom = false;
      _selected = value;
      _invalid = false;
    });
  }

  void _selectCustom() {
    setState(() {
      _isCustom = true;
      _invalid = false;
      if (_customController.text.isEmpty) {
        _customController.text = '$_selected';
      }
    });
  }

  void _save() {
    final value = _isCustom
        ? int.tryParse(_customController.text.trim())
        : _selected;

    if (value == null ||
        value < SessionSizeSheet.minWords ||
        value > SessionSizeSheet.maxWords) {
      setState(() => _invalid = true);
      return;
    }

    Navigator.of(context).pop(value);
  }
}
