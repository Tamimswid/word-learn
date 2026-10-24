import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordlearn/core/errors/failure.dart';
import 'package:wordlearn/core/state/load_status.dart';
import 'package:wordlearn/features/auth/auth.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({AuthUser? initialUser}) : _currentUser = initialUser;

  final StreamController<Either<Failure, AuthUser?>> _changes =
      StreamController<Either<Failure, AuthUser?>>.broadcast();
  AuthUser? _currentUser;
  Failure? signInFailure;
  Failure? signOutFailure;

  @override
  Stream<Either<Failure, AuthUser?>> watchAuthUser() async* {
    yield Right<Failure, AuthUser?>(_currentUser);
    yield* _changes.stream;
  }

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    final failure = signInFailure;
    if (failure != null) return Left(failure);

    const user = AuthUser(
      id: 'u1',
      email: 'ayse@gmail.com',
      displayName: 'Ayşe Yılmaz',
    );
    _currentUser = user;
    _changes.add(const Right<Failure, AuthUser?>(user));
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    final failure = signOutFailure;
    if (failure != null) return Left(failure);

    _currentUser = null;
    _changes.add(const Right<Failure, AuthUser?>(null));
    return const Right(unit);
  }

  Future<void> dispose() => _changes.close();
}

({AuthCubit cubit, _FakeAuthRepository repository}) _create({
  AuthUser? initialUser,
}) {
  final repository = _FakeAuthRepository(initialUser: initialUser);
  final cubit = AuthCubit(repository)..initialize();

  addTearDown(repository.dispose);
  addTearDown(cubit.close);

  return (cubit: cubit, repository: repository);
}

void main() {
  test('initialize resolves to unauthenticated without a session', () async {
    final deps = _create();

    await pumpEventQueue();

    expect(deps.cubit.state.isUnauthenticated, isTrue);
    expect(deps.cubit.state.user, isNull);
  });

  test('initialize restores an existing session', () async {
    final deps = _create(
      initialUser: const AuthUser(
        id: 'u1',
        email: 'ayse@gmail.com',
        displayName: 'Ayşe Yılmaz',
      ),
    );

    await pumpEventQueue();

    expect(deps.cubit.state.isAuthenticated, isTrue);
    expect(deps.cubit.state.firstName, 'Ayşe');
    expect(deps.cubit.state.initials, 'AY');
  });

  test('sign in emits loading and signs the user in', () async {
    final deps = _create();
    await pumpEventQueue();

    final actions = <LoadStatus>[];
    deps.cubit.stream.listen((state) {
      actions.add(state.action);
    });

    await deps.cubit.signInWithGoogle();
    await pumpEventQueue();

    expect(actions, contains(LoadStatus.loading));
    expect(deps.cubit.state.isAuthenticated, isTrue);
    expect(deps.cubit.state.user?.email, 'ayse@gmail.com');
  });

  test('sign in surfaces the repository failure message', () async {
    final deps = _create();
    await pumpEventQueue();
    deps.repository.signInFailure = const Failure(
      'Google girişi reddedildi.',
      type: FailureType.authentication,
      code: 'denied',
    );

    await deps.cubit.signInWithGoogle();

    expect(deps.cubit.state.hasError, isTrue);
    expect(deps.cubit.state.errorMessage, 'Google girişi reddedildi.');
    expect(deps.cubit.state.isBusy, isFalse);
  });

  test('clearError resets the failure status', () async {
    final deps = _create();
    await pumpEventQueue();
    deps.repository.signInFailure = const Failure('Hata');

    await deps.cubit.signInWithGoogle();
    deps.cubit.clearError();

    expect(deps.cubit.state.hasError, isFalse);
    expect(deps.cubit.state.action, LoadStatus.idle);
  });

  test('sign out clears the user', () async {
    final deps = _create();
    await pumpEventQueue();
    await deps.cubit.signInWithGoogle();
    await pumpEventQueue();

    await deps.cubit.signOut();
    await pumpEventQueue();

    expect(deps.cubit.state.isUnauthenticated, isTrue);
    expect(deps.cubit.state.user, isNull);
  });

  testWidgets('BlocSelector exposes shared auth state', (tester) async {
    final deps = _create();

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: deps.cubit,
        child: const MaterialApp(home: _AuthProbe()),
      ),
    );
    await tester.pump();

    expect(find.text('out'), findsOneWidget);
  });
}

class _AuthProbe extends StatelessWidget {
  const _AuthProbe();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, String>(
      selector: (state) => state.isAuthenticated ? state.displayName : 'out',
      builder: (context, value) => Text(value),
    );
  }
}
