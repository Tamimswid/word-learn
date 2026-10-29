import 'package:flutter/foundation.dart';

/// Derives how often the app nudges the user to come back.
///
/// The interval is spread across the reminder window instead of being fixed
/// (`interval = window / targetPrompts`) and clamped so prompts neither crowd
/// nor go silent for too long. Retune the cadence by changing these numbers.
@immutable
class ReminderCadence {
  const ReminderCadence({
    this.targetPrompts = 5,
    this.minInterval = const Duration(hours: 1),
    this.maxInterval = const Duration(hours: 4),
  });

  static const ReminderCadence standard = ReminderCadence();

  /// Prompts aimed for inside a single window.
  final int targetPrompts;

  final Duration minInterval;
  final Duration maxInterval;

  Duration intervalFor(int windowMinutes) {
    final minutes = (windowMinutes / targetPrompts).round();
    return Duration(
      minutes: minutes
          .clamp(minInterval.inMinutes, maxInterval.inMinutes)
          .toInt(),
    );
  }
}
