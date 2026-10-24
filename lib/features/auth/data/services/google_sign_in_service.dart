import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/failure.dart';

/// Owns the native Google Sign-In flow and returns the Google ID token that
/// Supabase verifies through `signInWithIdToken`.
class GoogleSignInService {
  GoogleSignInService({required this.webClientId, required this.iosClientId});

  final String webClientId;
  final String iosClientId;

  Future<void>? _initialization;

  Future<Either<Failure, String>> getIdToken() async {
    final missingClientId = _missingClientIdMessage();
    if (missingClientId != null) {
      return Left(
        Failure(
          missingClientId,
          type: FailureType.authentication,
          code: 'google_client_id_missing',
        ),
      );
    }

    try {
      await _ensureInitialized();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return const Left(
          Failure(
            'Bu platformda Google girişi desteklenmiyor.',
            type: FailureType.authentication,
            code: 'google_sign_in_unsupported',
          ),
        );
      }

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const Left(
          Failure(
            'Google kimlik anahtarı alınamadı. Lütfen tekrar deneyin.',
            type: FailureType.authentication,
            code: 'google_id_token_missing',
          ),
        );
      }

      return Right(idToken);
    } on GoogleSignInException catch (error, stackTrace) {
      return Left(
        Failure(
          error.code == GoogleSignInExceptionCode.canceled
              ? 'Google girişi iptal edildi.'
              : 'Google ile giriş yapılamadı. Lütfen tekrar deneyin.',
          type: FailureType.authentication,
          code: error.code.name,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } catch (error, stackTrace) {
      return Left(
        Failure(
          'Google ile giriş yapılamadı. Lütfen tekrar deneyin.',
          type: FailureType.authentication,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Clears the local Google session after Supabase signs the user out.
  ///
  /// This is best-effort: a Google cleanup failure must not turn a successful
  /// sign-out into an error.
  Future<void> signOut() async {
    final initialization = _initialization;
    if (initialization == null) return;

    try {
      await initialization;
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore Google session cleanup failures.
    }
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= GoogleSignIn.instance.initialize(
      clientId: _clientId,
      serverClientId: webClientId.isEmpty ? null : webClientId,
    );
  }

  String? get _clientId {
    final isApplePlatform =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    return isApplePlatform ? iosClientId : null;
  }

  String? _missingClientIdMessage() {
    final isApplePlatform =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (isApplePlatform && iosClientId.isEmpty) {
      return 'Google girişi için iOS istemci kimliği yapılandırılmamış.';
    }
    if (!isApplePlatform && webClientId.isEmpty) {
      return 'Google girişi için web istemci kimliği yapılandırılmamış.';
    }
    return null;
  }
}
