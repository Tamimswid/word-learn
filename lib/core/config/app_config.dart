import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration loaded from `.env`, with `--dart-define` fallbacks.
///
/// Values in `.env` are bundled into the app and are therefore public. Never
/// put server-only credentials (for example a Supabase service_role key) here.
abstract final class AppConfig {
  static const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
  static const String _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const String _googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );
  static const String _authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
  );

  static String get supabaseUrl => _read('SUPABASE_URL', _supabaseUrl);

  static String get supabaseAnonKey =>
      _read('SUPABASE_ANON_KEY', _supabaseAnonKey);

  /// Web OAuth client ID. Android also uses this as its server client ID.
  static String get googleWebClientId =>
      _read('GOOGLE_WEB_CLIENT_ID', _googleWebClientId);

  /// iOS OAuth client ID.
  static String get googleIosClientId =>
      _read('GOOGLE_IOS_CLIENT_ID', _googleIosClientId);

  /// Custom URL scheme used by the desktop OAuth return flow.
  static String get authRedirectUrl =>
      _read('AUTH_REDIRECT_URL', _authRedirectUrl);

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String _read(String key, String fallback) {
    final value = dotenv.isInitialized ? dotenv.maybeGet(key)?.trim() : null;
    if (value != null && value.isNotEmpty) return value;
    return fallback.trim();
  }
}
