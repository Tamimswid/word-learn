import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase_client.dart';
import '../platform/speech_to_text_service.dart';
import '../platform/text_to_speech_service.dart';
import '../platform/translation_service.dart';
import 'src/ai_tutor_injection.dart';
import 'src/auth_injection.dart';
import 'src/deck_session_injection.dart';
import 'src/home_dashboard_injection.dart';
import 'src/micro_exercise_injection.dart';
import 'src/quick_capture_injection.dart';
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

  if (!locator.isRegistered<TextToSpeechService>()) {
    locator.registerLazySingleton<TextToSpeechService>(TextToSpeechService.new);
  }

  if (!locator.isRegistered<SpeechToTextService>()) {
    locator.registerLazySingleton<SpeechToTextService>(SpeechToTextService.new);
  }

  if (!locator.isRegistered<TranslationService>()) {
    locator.registerLazySingleton<TranslationService>(TranslationService.new);
  }

  registerAuthDependencies(locator);
  registerWordManagementDependencies(locator);
  registerHomeDashboardDependencies(locator);
  registerDeckSessionDependencies(locator);
  registerMicroExerciseDependencies(locator);
  registerReminderDependencies(locator);
  registerQuickCaptureDependencies(locator);
  registerAiTutorDependencies(locator);
}
