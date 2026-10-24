import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/reminder_settings.dart';

/// Reads the reminder preference and keeps the OS schedule in sync.
abstract interface class ReminderRepository {
  Future<ReminderSettings> loadSettings();

  /// Persists [settings] and immediately reschedules the notifications.
  Future<Either<Failure, ReminderSettings>> saveSettings(
    ReminderSettings settings,
  );

  /// Rebuilds the schedule from the stored settings and today's deck.
  Future<Either<Failure, Unit>> reschedule();
}
