import 'package:flutter/foundation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/state/load_status.dart';
import '../../data/models/auth_user.dart';

enum AuthSessionStatus { unknown, authenticated, unauthenticated }

@immutable
class AuthState {
  const AuthState({
    this.session = AuthSessionStatus.unknown,
    this.action = LoadStatus.idle,
    this.user,
    this.failure,
  });

  final AuthSessionStatus session;
  final LoadStatus action;
  final AuthUser? user;
  final Failure? failure;

  bool get isInitializing => session == AuthSessionStatus.unknown;
  bool get isAuthenticated =>
      session == AuthSessionStatus.authenticated && user != null;
  bool get isUnauthenticated => session == AuthSessionStatus.unauthenticated;
  bool get isBusy => action.isLoading;
  bool get hasError => action.isFailure && failure != null;

  String? get errorMessage => failure?.message;
  String get displayName => user?.displayName ?? '';
  String get firstName => user?.firstName ?? '';
  String get initials => user?.initials ?? '?';

  AuthState copyWith({
    AuthSessionStatus? session,
    LoadStatus? action,
    AuthUser? user,
    Failure? failure,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      session: session ?? this.session,
      action: action ?? this.action,
      user: clearUser ? null : (user ?? this.user),
      failure: clearError ? null : (failure ?? this.failure),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthState &&
            other.session == session &&
            other.action == action &&
            other.user == user &&
            other.failure == failure;
  }

  @override
  int get hashCode => Object.hash(session, action, user, failure);
}
