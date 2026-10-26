import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../reminder/data/models/reminder_settings.dart';
import '../../../reminder/presentation/cubit/reminder_cubit.dart';
import '../../../reminder/presentation/cubit/reminder_state.dart';
import '../../../reminder/presentation/widgets/reminder_section.dart';
import '../widgets/session_size_section.dart';

class HomeSettingsResult {
  const HomeSettingsResult({
    required this.sessionSize,
    required this.reminderSaved,
  });

  final int sessionSize;
  final bool reminderSaved;
}

Future<HomeSettingsResult?> showHomeSettingsSheet(
  BuildContext context, {
  required int initialSessionSize,
}) {
  return showModalBottomSheet<HomeSettingsResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => BlocProvider<ReminderCubit>(
      create: (_) => locator<ReminderCubit>()..load(),
      child: HomeSettingsSheet(initialSessionSize: initialSessionSize),
    ),
  );
}

class HomeSettingsSheet extends StatefulWidget {
  const HomeSettingsSheet({super.key, required this.initialSessionSize});

  final int initialSessionSize;

  @override
  State<HomeSettingsSheet> createState() => _HomeSettingsSheetState();
}

class _HomeSettingsSheetState extends State<HomeSettingsSheet> {
  late final TextEditingController _customController;
  late bool _isCustom;
  late int _selected;
  bool _invalid = false;
  ReminderSettings? _initialReminder;

  @override
  void initState() {
    super.initState();
    _isCustom = !SessionSizeSection.presets.contains(widget.initialSessionSize);
    _selected = _isCustom
        ? SessionSizeSection.presets[1]
        : widget.initialSessionSize;
    _customController = TextEditingController(
      text: _isCustom ? '${widget.initialSessionSize}' : '',
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReminderCubit, ReminderState>(
      listenWhen: (previous, current) => current.isSaved && !previous.isSaved,
      listener: (context, _) => _close(reminderSaved: true),
      child: BlocBuilder<ReminderCubit, ReminderState>(
        builder: (context, state) {
          if (!state.hasLoaded) return const _SheetLoading();
          _initialReminder ??= state.settings;

          final cubit = context.read<ReminderCubit>();

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
                  SessionSizeSection(
                    selected: _selected,
                    isCustom: _isCustom,
                    customController: _customController,
                    invalid: _invalid,
                    onSelectPreset: _selectPreset,
                    onSelectCustom: _selectCustom,
                    onCustomChanged: _handleCustomChanged,
                    onCustomSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(
                    height: 1,
                    thickness: AppBorders.width,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ReminderSection(
                    state: state,
                    onEnabledChanged: cubit.setEnabled,
                    onStartMinutesChanged: cubit.setStartMinutes,
                    onEndMinutesChanged: cubit.setEndMinutes,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _SheetActions(
                    isSaving: state.isLoading,
                    canSave: state.settings.isValid,
                    onCancel: () => Navigator.of(context).pop(),
                    onSave: _save,
                  ),
                ],
              ),
            ),
          );
        },
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

  void _handleCustomChanged(String _) {
    if (_invalid) setState(() => _invalid = false);
  }

  void _save() {
    final value = _sessionSize;
    if (value == null ||
        value < SessionSizeSection.minWords ||
        value > SessionSizeSection.maxWords) {
      setState(() => _invalid = true);
      return;
    }

    _selected = value;

    final cubit = context.read<ReminderCubit>();
    if (cubit.state.settings == _initialReminder) {
      _close(reminderSaved: false);
      return;
    }

    cubit.save();
  }

  int? get _sessionSize {
    if (!_isCustom) return _selected;
    return int.tryParse(_customController.text.trim());
  }

  void _close({required bool reminderSaved}) {
    Navigator.of(context).pop(
      HomeSettingsResult(sessionSize: _selected, reminderSaved: reminderSaved),
    );
  }
}

class _SheetLoading extends StatelessWidget {
  const _SheetLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.giant),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({
    required this.isSaving,
    required this.canSave,
    required this.onCancel,
    required this.onSave,
  });

  final bool isSaving;
  final bool canSave;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.sm,
      children: [
        Expanded(
          child: AppButton(
            label: 'Vazgeç',
            variant: AppButtonVariant.secondary,
            expanded: true,
            onPressed: isSaving ? null : onCancel,
          ),
        ),
        Expanded(
          child: AppButton(
            label: 'Kaydet',
            expanded: true,
            isLoading: isSaving,
            onPressed: isSaving || !canSave ? null : onSave,
          ),
        ),
      ],
    );
  }
}
