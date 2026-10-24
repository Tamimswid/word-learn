import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordlearn/core/errors/failure.dart';
import 'package:wordlearn/features/auth/data/services/google_sign_in_service.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'fails before touching the plugin when the web client ID is missing',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final service = GoogleSignInService(
        webClientId: '',
        iosClientId: 'ios-client-id.apps.googleusercontent.com',
      );

      final result = await service.getIdToken();

      expect(result.isLeft(), isTrue);
      result.fold((failure) {
        expect(failure.type, FailureType.authentication);
        expect(failure.code, 'google_client_id_missing');
      }, (_) => fail('Expected a configuration failure.'));
    },
  );

  test('requires an iOS client ID on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final service = GoogleSignInService(
      webClientId: 'web-client-id.apps.googleusercontent.com',
      iosClientId: '',
    );

    final result = await service.getIdToken();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.code, 'google_client_id_missing'),
      (_) => fail('Expected a configuration failure.'),
    );
  });

  test('requires an iOS client ID on macOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

    final service = GoogleSignInService(
      webClientId: 'web-client-id.apps.googleusercontent.com',
      iosClientId: '',
    );

    final result = await service.getIdToken();

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure.code, 'google_client_id_missing'),
      (_) => fail('Expected a configuration failure.'),
    );
  });

  test('signOut is a no-op before the plugin is initialized', () async {
    final service = GoogleSignInService(webClientId: '', iosClientId: '');

    await expectLater(service.signOut(), completes);
  });
}
