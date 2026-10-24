import '../models/reminder_slot.dart';

/// Schedules and clears the operating system notifications.
abstract interface class NotificationDataSource {
  /// Asks for the platform notification permission when needed.
  Future<bool> requestPermissions();

  Future<void> schedule(ReminderSlot slot, int id);

  Future<void> cancelScheduled();
}
