import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// App-wide auth state. Owned by the locator.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;
  StreamSubscription<Either<Failure, AuthUser?>>? _sessionSubscription;

  void initialize() {
    if (_sessionSubscription != null) return;
    _sessionSubscription = _repository.watchAuthUser().listen(_handleSession);
  }

  Future<void> signInWithGoogle() async {
    if (state.isBusy) return;
    _emit(state.copyWith(action: LoadStatus.loading, clearError: true));

    final result = await _repository.signInWithGoogle();
    result.fold(
      _fail,
      (_) =>
          _emit(state.copyWith(action: LoadStatus.success, clearError: true)),
    );
  }

  Future<void> signOut() async {
    if (state.isBusy) return;
    _emit(state.copyWith(action: LoadStatus.loading, clearError: true));

    final result = await _repository.signOut();
    result.fold(
      _fail,
      (_) => _emit(
        const AuthState(
          session: AuthSessionStatus.unauthenticated,
          action: LoadStatus.success,
        ),
      ),
    );
  }

  void clearError() {
    if (state.failure == null && !state.action.isFailure) return;
    _emit(state.copyWith(action: LoadStatus.idle, clearError: true));
  }

  void _handleSession(Either<Failure, AuthUser?> result) {
    result.fold(_fail, _handleUser);
  }

  void _handleUser(AuthUser? user) {
    if (user == null) {
      _emit(
        state.copyWith(
          session: AuthSessionStatus.unauthenticated,
          action: LoadStatus.idle,
          clearUser: true,
          clearError: true,
        ),
      );
      return;
    }

    _emit(
      state.copyWith(
        session: AuthSessionStatus.authenticated,
        user: user,
        action: LoadStatus.idle,
        clearError: true,
      ),
    );
  }

  void _fail(Failure failure) {
    _emit(state.copyWith(action: LoadStatus.failure, failure: failure));
  }

  void _emit(AuthState next) {
    if (next == state) return;
    emit(next);
  }

  @override
  Future<void> close() {
    unawaited(_sessionSubscription?.cancel());
    _sessionSubscription = null;
    return super.close();
  }
}
