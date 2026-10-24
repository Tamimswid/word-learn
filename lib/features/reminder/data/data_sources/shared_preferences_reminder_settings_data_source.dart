import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder_settings.dart';
import 'reminder_settings_data_source.dart';

class SharedPreferencesReminderSettingsDataSource
    implements ReminderSettingsDataSource {
  static const String _enabledKey = 'reminder_enabled';
  static const String _startKey = 'reminder_start_minutes';
  static const String _endKey = 'reminder_end_minutes';

  static const ReminderSettings _defaults = ReminderSettings();

  @override
  Future<ReminderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ReminderSettings(
      isEnabled: prefs.getBool(_enabledKey) ?? _defaults.isEnabled,
      startMinutes: prefs.getInt(_startKey) ?? _defaults.startMinutes,
      endMinutes: prefs.getInt(_endKey) ?? _defaults.endMinutes,
    );
  }

  @override
  Future<void> save(ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, settings.isEnabled);
    await prefs.setInt(_startKey, settings.startMinutes);
    await prefs.setInt(_endKey, settings.endMinutes);
  }
}
