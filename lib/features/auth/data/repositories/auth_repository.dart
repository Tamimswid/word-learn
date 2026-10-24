import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/auth_user.dart';

abstract interface class AuthRepository {
  /// Emits the current user immediately, then every session change.
  Stream<Either<Failure, AuthUser?>> watchAuthUser();

  Future<Either<Failure, Unit>> signInWithGoogle();

  Future<Either<Failure, Unit>> signOut();
}
