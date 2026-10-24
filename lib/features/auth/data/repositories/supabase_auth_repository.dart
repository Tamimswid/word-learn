import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_handler.dart';
import '../models/auth_user.dart';
import '../services/google_sign_in_service.dart';
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, this._googleSignIn);

  final supabase.SupabaseClient _client;
  final GoogleSignInService _googleSignIn;

  @override
  Stream<Either<Failure, AuthUser?>> watchAuthUser() async* {
    yield Right(_mapUser(_client.auth.currentUser));

    try {
      await for (final state in _client.auth.onAuthStateChange) {
        yield Right(_mapUser(state.session?.user));
      }
    } catch (error, stackTrace) {
      yield Left(SupabaseErrorHandler.map(error, stackTrace: stackTrace));
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    // The browser-based OAuth flow is still used on web and on desktop
    // platforms that do not support the native Google Sign-In plugin.
    if (!_supportsNativeGoogleSignIn) {
      return _signInWithOAuth();
    }

    final tokenResult = await _googleSignIn.getIdToken();
    return tokenResult.fold<Future<Either<Failure, Unit>>>(
      (failure) async => Left(failure),
      _signInWithIdToken,
    );
  }

  Future<Either<Failure, Unit>> _signInWithIdToken(String idToken) async {
    try {
      final response = await _client.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
      );

      if (response.session == null) {
        return const Left(
          Failure(
            'Google oturumu oluşturulamadı. Lütfen tekrar deneyin.',
            type: FailureType.authentication,
          ),
        );
      }

      return const Right(unit);
    } catch (error, stackTrace) {
      // GoTrue reports a rejected Google ID token as `invalid_credentials`;
      // avoid showing the email/password error copy for this flow.
      if (error is supabase.AuthException &&
          error is! supabase.AuthRetryableFetchException) {
        final failure = SupabaseErrorHandler.map(error, stackTrace: stackTrace);
        if (failure.code == 'invalid_credentials' ||
            failure.code == 'invalid_grant') {
          return Left(
            Failure(
              'Google kimlik doğrulaması doğrulanamadı. Lütfen tekrar deneyin.',
              type: FailureType.authentication,
              code: failure.code,
              cause: error,
              stackTrace: stackTrace,
            ),
          );
        }
        return Left(failure);
      }

      return Left(
        SupabaseErrorHandler.map(
          error,
          stackTrace: stackTrace,
          fallbackMessage:
              'Google ile giriş tamamlanamadı. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  Future<Either<Failure, Unit>> _signInWithOAuth() async {
    try {
      final launched = await _client.auth.signInWithOAuth(
        supabase.OAuthProvider.google,
        redirectTo: _oauthRedirectUrl,
      );
      if (!launched) {
        return const Left(
          Failure(
            'Google giriş ekranı açılamadı. Lütfen tekrar deneyin.',
            type: FailureType.authentication,
          ),
        );
      }
      return const Right(unit);
    } catch (error, stackTrace) {
      return Left(
        SupabaseErrorHandler.map(
          error,
          stackTrace: stackTrace,
          fallbackMessage:
              'Google ile giriş başlatılamadı. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _client.auth.signOut();
      await _googleSignIn.signOut();
      return const Right(unit);
    } catch (error, stackTrace) {
      return Left(
        SupabaseErrorHandler.map(
          error,
          stackTrace: stackTrace,
          fallbackMessage: 'Çıkış yapılamadı. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  AuthUser? _mapUser(supabase.User? user) {
    if (user == null) return null;

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final name = metadata['full_name'] ?? metadata['name'];
    final avatar = metadata['avatar_url'] ?? metadata['picture'];
    final fallbackName = user.email?.split('@').first ?? 'Kullanıcı';

    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      displayName: name is String && name.trim().isNotEmpty
          ? name.trim()
          : fallbackName,
      photoUrl: avatar is String && avatar.isNotEmpty ? avatar : null,
    );
  }

  bool get _supportsNativeGoogleSignIn {
    if (kIsWeb) return false;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  /// macOS returns through a custom URL scheme after the browser OAuth flow.
  String? get _oauthRedirectUrl {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.macOS) return null;
    final url = AppConfig.authRedirectUrl;
    return url.isEmpty ? null : url;
  }
}
