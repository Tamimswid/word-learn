import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_route.dart';

/// Typed shortcuts around go_router's [BuildContext] helpers.
///
/// Instead of repeating `context.go('/deck')`, features call
/// `context.goTo(AppRoute.deck)`.
extension AppNavigation on BuildContext {
  /// Replaces the current location (no back entry).
  void goTo(
    AppRoute route, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
  }) {
    go(
      route.location(
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      ),
      extra: extra,
    );
  }

  /// Pushes [route] on top of the current stack.
  Future<T?> pushRoute<T extends Object?>(
    AppRoute route, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
  }) {
    return push<T>(
      route.location(
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      ),
      extra: extra,
    );
  }

  /// Replaces the current page with [route].
  Future<T?> replaceRoute<T extends Object?>(
    AppRoute route, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
  }) {
    return GoRouter.of(this).pushReplacement<T>(
      route.location(
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      ),
      extra: extra,
    );
  }

  /// Pops the current page when possible.
  void goBack<T extends Object?>([T? result]) {
    final router = GoRouter.of(this);
    if (router.canPop()) router.pop<T>(result);
  }
}
