import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../data/models/reminder_settings.dart';

@immutable
class ReminderState {
  const ReminderState({
    this.settings = const ReminderSettings(),
    this.status = LoadStatus.idle,
    this.failure,
    this.isSaved = false,
    this.hasLoaded = false,
  });

  final ReminderSettings settings;
  final LoadStatus status;
  final Failure? failure;
  final bool isSaved;
  final bool hasLoaded;

  bool get isLoading => status.isLoading;
  String? get errorMessage => failure?.message;

  ReminderState copyWith({
    ReminderSettings? settings,
    LoadStatus? status,
    Failure? failure,
    bool clearFailure = false,
    bool? isSaved,
    bool? hasLoaded,
  }) {
    return ReminderState(
      settings: settings ?? this.settings,
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      isSaved: isSaved ?? this.isSaved,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}
