import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

/// Converts Supabase and transport errors into the common [Failure].
abstract final class SupabaseErrorHandler {
  static const String _unexpectedMessage =
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';

  static Failure map(
    Object error, {
    StackTrace? stackTrace,
    String? fallbackMessage,
  }) {
    if (error is Failure) return error;

    if (error is AuthRetryableFetchException) {
      return Failure(
        'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.',
        type: FailureType.network,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is AuthException) {
      return _mapAuth(error, stackTrace);
    }

    if (error is PostgrestException) {
      return _mapPostgrest(error, stackTrace);
    }

    if (error is FunctionException) {
      return _mapFunction(error, stackTrace, fallbackMessage);
    }

    if (error is StorageException) {
      return Failure(
        'Dosya işlemi tamamlanamadı. Lütfen tekrar deneyin.',
        type: FailureType.storage,
        code: error.statusCode,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return Failure(
        'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.',
        type: FailureType.timeout,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    return Failure(
      fallbackMessage ?? _unexpectedMessage,
      cause: error,
      stackTrace: stackTrace,
    );
  }

  static Failure _mapAuth(AuthException error, StackTrace? stackTrace) {
    final (message, type) = switch (error.code) {
      'invalid_credentials' || 'invalid_grant' => (
        'E-posta veya şifre hatalı.',
        FailureType.authentication,
      ),
      'email_not_confirmed' => (
        'E-posta adresiniz henüz doğrulanmadı.',
        FailureType.authentication,
      ),
      'user_not_found' => ('Kullanıcı bulunamadı.', FailureType.notFound),
      'user_already_exists' || 'email_exists' => (
        'Bu e-posta adresiyle bir hesap zaten var.',
        FailureType.conflict,
      ),
      'weak_password' => (
        'Şifreniz çok zayıf. Daha güçlü bir şifre deneyin.',
        FailureType.authentication,
      ),
      'session_not_found' || 'session_expired' || 'refresh_token_not_found' => (
        'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
        FailureType.authentication,
      ),
      'over_request_rate_limit' || 'over_email_send_rate_limit' => (
        'Çok fazla deneme yaptınız. Lütfen biraz sonra tekrar deneyin.',
        FailureType.authentication,
      ),
      'provider_disabled' || 'oauth_provider_not_supported' => (
        'Bu giriş yöntemi şu anda kullanılamıyor.',
        FailureType.authentication,
      ),
      'signup_disabled' => (
        'Yeni kayıtlar şu anda kapalı.',
        FailureType.permission,
      ),
      _ => (
        'Kimlik doğrulama işlemi tamamlanamadı. Lütfen tekrar deneyin.',
        FailureType.authentication,
      ),
    };

    return Failure(
      message,
      type: type,
      code: error.code,
      cause: error,
      stackTrace: stackTrace,
    );
  }

  static Failure _mapFunction(
    FunctionException error,
    StackTrace? stackTrace,
    String? fallbackMessage,
  ) {
    final details = error.details;
    final serverError = details is Map ? details['error'] : null;
    final serverMessage = serverError is String ? serverError : null;

    if (serverMessage != null &&
        (serverMessage.contains('23505') ||
            serverMessage.toLowerCase().contains('duplicate key'))) {
      return Failure(
        'Bu kelime zaten eklenmiş.',
        type: FailureType.conflict,
        code: '23505',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    final (message, type) = switch (error.status) {
      0 => (
        'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.',
        FailureType.network,
      ),
      401 => (
        'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
        FailureType.authentication,
      ),
      403 => ('Bu işlem için yetkiniz yok.', FailureType.permission),
      404 => (
        'İstenen hizmet bulunamadı. Lütfen tekrar deneyin.',
        FailureType.notFound,
      ),
      409 => ('Bu kayıt zaten mevcut.', FailureType.conflict),
      429 => (
        'Çok fazla istek gönderildi. Lütfen biraz sonra tekrar deneyin.',
        FailureType.unexpected,
      ),
      _ => (fallbackMessage ?? _unexpectedMessage, FailureType.unexpected),
    };

    return Failure(
      message,
      type: type,
      code: error.status.toString(),
      cause: error,
      stackTrace: stackTrace,
    );
  }

  static Failure _mapPostgrest(
    PostgrestException error,
    StackTrace? stackTrace,
  ) {
    final (message, type) = switch (error.code) {
      '42501' => ('Bu işlem için yetkiniz yok.', FailureType.permission),
      '23505' => ('Bu kayıt zaten mevcut.', FailureType.conflict),
      'PGRST116' => ('Aradığınız kayıt bulunamadı.', FailureType.notFound),
      _ => (
        'İstek tamamlanamadı. Lütfen tekrar deneyin.',
        FailureType.unexpected,
      ),
    };

    return Failure(
      message,
      type: type,
      code: error.code,
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
