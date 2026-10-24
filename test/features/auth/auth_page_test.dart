import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordlearn/core/design_system/app_assets.dart';
import 'package:wordlearn/core/design_system/app_theme.dart';
import 'package:wordlearn/core/errors/failure.dart';
import 'package:wordlearn/features/auth/data/models/auth_user.dart';
import 'package:wordlearn/features/auth/data/repositories/auth_repository.dart';
import 'package:wordlearn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wordlearn/features/auth/presentation/widget/auth_content.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.signInFailure})
    : _delay = const Duration(milliseconds: 20);

  final Failure? signInFailure;
  final Duration _delay;
  final StreamController<Either<Failure, AuthUser?>> _changes =
      StreamController<Either<Failure, AuthUser?>>.broadcast();

  @override
  Stream<Either<Failure, AuthUser?>> watchAuthUser() async* {
    yield const Right<Failure, AuthUser?>(null);
    yield* _changes.stream;
  }

  @override
  Future<Either<Failure, Unit>> signInWithGoogle() async {
    await Future<void>.delayed(_delay);
    final failure = signInFailure;
    if (failure != null) return Left(failure);

    const user = AuthUser(
      id: 'u1',
      email: 'ayse@gmail.com',
      displayName: 'Ayşe Yılmaz',
    );
    _changes.add(const Right<Failure, AuthUser?>(user));
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    _changes.add(const Right<Failure, AuthUser?>(null));
    return const Right(unit);
  }

  Future<void> dispose() => _changes.close();
}

({AuthCubit cubit, _FakeAuthRepository repository}) _create({
  Failure? signInFailure,
}) {
  final repository = _FakeAuthRepository(signInFailure: signInFailure);
  final cubit = AuthCubit(repository)..initialize();

  addTearDown(repository.dispose);
  addTearDown(cubit.close);

  return (cubit: cubit, repository: repository);
}

Future<void> _pumpPage(WidgetTester tester, AuthCubit cubit) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  await tester.pumpWidget(
    BlocProvider<AuthCubit>.value(
      value: cubit,
      child: MaterialApp(theme: AppTheme.dark, home: const AuthContent()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders only the illustration and sign-in action', (
    tester,
  ) async {
    final deps = _create();

    await _pumpPage(tester, deps.cubit);

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.image(const AssetImage(AppAssets.signIn)), findsOneWidget);
    expect(find.image(const AssetImage(AppAssets.google)), findsOneWidget);
    expect(find.text('Karşılaştığın kelimeler, unutulmasın.'), findsNothing);
    expect(find.text('Google ile devam et'), findsNothing);
    expect(find.text('1'), findsNothing);
    expect(
      find.text('Devam ederek kullanım koşullarını kabul edersin.'),
      findsNothing,
    );
  });

  testWidgets('shows a spinner while signing in', (tester) async {
    final deps = _create();

    await _pumpPage(tester, deps.cubit);
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('surfaces a failed sign-in in a snack bar', (tester) async {
    final deps = _create(
      signInFailure: const Failure(
        'Bağlantını kontrol edip tekrar dene.',
        type: FailureType.network,
      ),
    );

    await _pumpPage(tester, deps.cubit);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Bağlantını kontrol edip tekrar dene.'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
