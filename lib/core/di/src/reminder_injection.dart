import 'package:get_it/get_it.dart';

import '../../../features/deck_session/deck_session.dart';
import '../../../features/reminder/data/data_sources/local_notification_data_source.dart';
import '../../../features/reminder/data/data_sources/notification_data_source.dart';
import '../../../features/reminder/data/data_sources/reminder_settings_data_source.dart';
import '../../../features/reminder/data/data_sources/shared_preferences_reminder_settings_data_source.dart';
import '../../../features/reminder/data/repositories/reminder_repository_impl.dart';
import '../../../features/reminder/reminder.dart';

void registerReminderDependencies(GetIt locator) {
  if (!locator.isRegistered<ReminderSettingsDataSource>()) {
    locator.registerLazySingleton<ReminderSettingsDataSource>(
      SharedPreferencesReminderSettingsDataSource.new,
    );
  }

  if (!locator.isRegistered<NotificationDataSource>()) {
    locator.registerLazySingleton<NotificationDataSource>(
      LocalNotificationDataSource.new,
    );
  }

  if (!locator.isRegistered<ReminderRepository>()) {
    locator.registerLazySingleton<ReminderRepository>(
      () => ReminderRepositoryImpl(
        locator<DeckRepository>(),
        locator<ReminderSettingsDataSource>(),
        locator<NotificationDataSource>(),
      ),
    );
  }

  if (!locator.isRegistered<ReminderCubit>()) {
    locator.registerFactory<ReminderCubit>(
      () => ReminderCubit(locator<ReminderRepository>()),
    );
  }
}
