import 'package:flutter_test/flutter_test.dart';
import 'package:wordlearn/core/router/router.dart';

void main() {
  group('AppRoute.location', () {
    test('returns the plain path when no arguments are given', () {
      expect(AppRoute.deck.location(), '/deck');
      expect(AppRoute.home.location(), '/');
    });

    test('fills and encodes path parameters', () {
      expect(
        AppRoute.wordDetail.location(
          pathParameters: {AppRouteParams.wordId: 'abc 123'},
        ),
        '/words/abc%20123',
      );
    });

    test('appends query parameters', () {
      expect(
        AppRoute.deck.location(queryParameters: {AppRouteQuery.from: 'home'}),
        '/deck?from=home',
      );
    });
  });

  test('route names and page keys are unique', () {
    final names = AppRoute.values.map((route) => route.name).toSet();
    final pageKeys = AppRoute.values.map((route) => route.pageKey).toSet();

    expect(names, hasLength(AppRoute.values.length));
    expect(pageKeys, hasLength(AppRoute.values.length));
  });
}
