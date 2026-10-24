import 'package:flutter/foundation.dart';

/// User preference for the daily word reminders.
@immutable
class ReminderSettings {
  const ReminderSettings({
    this.isEnabled = false,
    this.startMinutes = 9 * 60,
    this.endMinutes = 21 * 60,
  });

  /// Whether reminders should be scheduled at all.
  final bool isEnabled;

  /// Start of the window, as minutes since midnight.
  final int startMinutes;

  /// End of the window, as minutes since midnight.
  final int endMinutes;

  bool get isValid =>
      startMinutes >= 0 && endMinutes <= 24 * 60 && endMinutes > startMinutes;

  ReminderSettings copyWith({
    bool? isEnabled,
    int? startMinutes,
    int? endMinutes,
  }) {
    return ReminderSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReminderSettings &&
            other.isEnabled == isEnabled &&
            other.startMinutes == startMinutes &&
            other.endMinutes == endMinutes;
  }

  @override
  int get hashCode => Object.hash(isEnabled, startMinutes, endMinutes);
}
