import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase_client.dart';
import 'src/auth_injection.dart';
import 'src/deck_session_injection.dart';
import 'src/home_dashboard_injection.dart';
import 'src/micro_exercise_injection.dart';
import 'src/reminder_injection.dart';
import 'src/word_management_injection.dart';

/// Single locator shared by every feature.
final GetIt locator = GetIt.instance;

void setupLocator({SupabaseClient? supabaseClient}) {
  if (supabaseClient != null && !locator.isRegistered<SupabaseClient>()) {
    locator.registerSingleton<SupabaseClient>(supabaseClient);
  }

  if (!locator.isRegistered<AppSupabaseClient>() &&
      locator.isRegistered<SupabaseClient>()) {
    locator.registerLazySingleton<AppSupabaseClient>(
      () => AppSupabaseClient(locator<SupabaseClient>()),
    );
  }

  registerAuthDependencies(locator);
  registerWordManagementDependencies(locator);
  registerHomeDashboardDependencies(locator);
  registerDeckSessionDependencies(locator);
  registerMicroExerciseDependencies(locator);
  registerReminderDependencies(locator);
}
