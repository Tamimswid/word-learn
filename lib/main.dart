import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/di/app_locator.dart';
import 'features/quick_capture/quick_capture.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // `.env` is optional so the app can still start from `--dart-define`
  // values. Create it with `cp .env.example .env` for local development.
  await dotenv.load(isOptional: true);

  if (AppConfig.hasSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  setupLocator(
    supabaseClient: AppConfig.hasSupabase ? Supabase.instance.client : null,
  );

  if (Platform.isMacOS) {
    await locator<QuickCaptureCoordinator>().initialize();
  }

  runApp(const AppBootstrap());
}
