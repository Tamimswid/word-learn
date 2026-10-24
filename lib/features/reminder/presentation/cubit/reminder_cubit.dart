import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/state/load_status.dart';
import '../../data/models/reminder_settings.dart';
import '../../data/repositories/reminder_repository.dart';
import 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  ReminderCubit(this._repository) : super(const ReminderState());

  final ReminderRepository _repository;

  Future<void> load() async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: LoadStatus.loading,
        clearFailure: true,
        isSaved: false,
      ),
    );

    final settings = await _repository.loadSettings();
    emit(
      state.copyWith(
        settings: settings,
        status: LoadStatus.success,
        hasLoaded: true,
      ),
    );
  }

  void setEnabled(bool enabled) {
    _update(state.settings.copyWith(isEnabled: enabled));
  }

  void setStartMinutes(int minutes) {
    _update(state.settings.copyWith(startMinutes: minutes));
  }

  void setEndMinutes(int minutes) {
    _update(state.settings.copyWith(endMinutes: minutes));
  }

  Future<void> save() async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: LoadStatus.loading,
        clearFailure: true,
        isSaved: false,
      ),
    );

    final result = await _repository.saveSettings(state.settings);
    result.fold(
      (failure) => emit(
        state.copyWith(status: LoadStatus.failure, failure: failure),
      ),
      (settings) => emit(
        ReminderState(
          settings: settings,
          status: LoadStatus.success,
          isSaved: true,
        ),
      ),
    );
  }

  void _update(ReminderSettings settings) {
    emit(
      state.copyWith(
        settings: settings,
        clearFailure: true,
        isSaved: false,
      ),
    );
  }
}
