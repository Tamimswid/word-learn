import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

/// Development implementation used when Supabase is not configured.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({AuthUser? initialUser}) : _currentUser = initialUser;

  final StreamController<Either<Failure, AuthUser?>> _changes =
      StreamController<Either<Failure, AuthUser?>>.broadcast();
  AuthUser? _currentUser;

  @override
  Stream<Either<Failure, AuthUser?>> watchAuthUser() async* {
    yield Right(_currentUser);
    yield* _changes.stream;
  }

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    const user = AuthUser(
      id: 'demo-ayse',
      email: 'ayse@gmail.com',
      displayName: 'Ayşe Yılmaz',
    );
    _currentUser = user;
    _changes.add(const Right(user));
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _changes.add(const Right(null));
    return const Right(unit);
  }

  void dispose() => _changes.close();
}
