import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

/// Converts Supabase and transport errors into the common [Failure].
abstract final class SupabaseErrorHandler {
  static const String _unexpectedMessage =
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  static Failure map(
    Object error, {
    StackTrace? stackTrace,
    String? fallbackMessage,
  }) {
    if (error is Failure) return error;

    if (error is AuthRetryableFetchException) {
      return Failure(
        'تعذر الوصول إلى الخادم. تحقق من اتصالك بالإنترنت ثم حاول مرة أخرى.',
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
        'تعذر إكمال عملية الملف. يرجى المحاولة مرة أخرى.',
        type: FailureType.storage,
        code: error.statusCode,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return Failure(
        'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.',
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
        'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
        FailureType.authentication,
      ),
      'email_not_confirmed' => (
        'لم يتم تأكيد بريدك الإلكتروني بعد.',
        FailureType.authentication,
      ),
      'user_not_found' => ('لم يتم العثور على المستخدم.', FailureType.notFound),
      'user_already_exists' || 'email_exists' => (
        'يوجد حساب بهذا البريد الإلكتروني بالفعل.',
        FailureType.conflict,
      ),
      'weak_password' => (
        'كلمة المرور ضعيفة جدًا. جرّب كلمة مرور أقوى.',
        FailureType.authentication,
      ),
      'session_not_found' || 'session_expired' || 'refresh_token_not_found' => (
        'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.',
        FailureType.authentication,
      ),
      'over_request_rate_limit' || 'over_email_send_rate_limit' => (
        'لقد أجريت محاولات كثيرة جدًا. يرجى المحاولة بعد قليل.',
        FailureType.authentication,
      ),
      'provider_disabled' || 'oauth_provider_not_supported' => (
        'طريقة تسجيل الدخول هذه غير متاحة حاليًا.',
        FailureType.authentication,
      ),
      'signup_disabled' => (
        'التسجيل الجديد مغلق حاليًا.',
        FailureType.permission,
      ),
      _ => (
        'تعذر إكمال عملية التحقق. يرجى المحاولة مرة أخرى.',
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
        'تمت إضافة هذه الكلمة بالفعل.',
        type: FailureType.conflict,
        code: '23505',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    final (message, type) = switch (error.status) {
      0 => (
        'تعذر الوصول إلى الخادم. تحقق من اتصالك بالإنترنت ثم حاول مرة أخرى.',
        FailureType.network,
      ),
      401 => (
        'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.',
        FailureType.authentication,
      ),
      403 => ('لا تملك صلاحية لهذا الإجراء.', FailureType.permission),
      404 => (
        'لم يتم العثور على الخدمة المطلوبة. يرجى المحاولة مرة أخرى.',
        FailureType.notFound,
      ),
      409 => ('هذا السجل موجود بالفعل.', FailureType.conflict),
      429 => (
        'تم إرسال طلبات كثيرة جدًا. يرجى المحاولة بعد قليل.',
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
      '42501' => ('لا تملك صلاحية لهذا الإجراء.', FailureType.permission),
      '23505' => ('هذا السجل موجود بالفعل.', FailureType.conflict),
      'PGRST116' => ('لم يتم العثور على السجل الذي تبحث عنه.', FailureType.notFound),
      _ => (
        'تعذر إكمال الطلب. يرجى المحاولة مرة أخرى.',
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
