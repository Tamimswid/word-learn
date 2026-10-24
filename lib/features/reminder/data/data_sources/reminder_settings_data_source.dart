import '../models/reminder_settings.dart';

/// Persists the reminder preference between app launches.
abstract interface class ReminderSettingsDataSource {
  Future<ReminderSettings> load();

  Future<void> save(ReminderSettings settings);
}
