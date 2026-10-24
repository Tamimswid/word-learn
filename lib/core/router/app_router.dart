import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/pages/auth_page.dart';
import '../../../features/deck_session/presentation/pages/deck_page.dart';
import '../../../features/home_dashboard/presentation/pages/home_page.dart';
import '../../../features/micro_exercise/presentation/pages/exercise_page.dart';
import '../keys/app_keys.dart';
import 'app_route.dart';
import 'pages/route_error_page.dart';
import 'pages/route_placeholder_page.dart';

/// Builds the app-wide [GoRouter].
///
/// The router is intentionally created per app instance (not as a global
/// singleton) so tests and hot restarts get a clean navigation stack.
///
/// Pass [redirect] together with [refreshListenable] (for example the shared
/// auth cubit) to gate routes on authentication.
abstract final class AppRouter {
  /// Enables state restoration for the navigation stack.
  static const String restorationScopeId = 'appRouter';

  static GoRouter create({
    String initialLocation = '/',
    GoRouterRedirect? redirect,
    Listenable? refreshListenable,
  }) {
    return GoRouter(
      navigatorKey: AppKeys.rootNavigator,
      restorationScopeId: restorationScopeId,
      initialLocation: initialLocation,
      debugLogDiagnostics: kDebugMode,
      redirect: redirect,
      refreshListenable: refreshListenable,
      routes: _routes,
      errorBuilder: (context, state) => RouteErrorPage(
        location: state.uri.toString(),
        message: state.error?.message,
      ),
    );
  }

  static final List<RouteBase> _routes = <RouteBase>[
    GoRoute(
      path: AppRoute.home.path,
      name: AppRoute.home.name,
      pageBuilder: (context, state) => _page(AppRoute.home, const HomePage()),
    ),
    GoRoute(
      path: AppRoute.addWord.path,
      name: AppRoute.addWord.name,
      pageBuilder: (context, state) => _page(
        AppRoute.addWord,
        const RoutePlaceholderPage(route: AppRoute.addWord),
      ),
    ),
    GoRoute(
      path: AppRoute.wordDetail.path,
      name: AppRoute.wordDetail.name,
      pageBuilder: (context, state) => _page(
        AppRoute.wordDetail,
        RoutePlaceholderPage(
          route: AppRoute.wordDetail,
          pathParameters: state.pathParameters,
        ),
      ),
    ),
    GoRoute(
      path: AppRoute.deck.path,
      name: AppRoute.deck.name,
      pageBuilder: (context, state) => _page(AppRoute.deck, const DeckPage()),
    ),
    GoRoute(
      path: AppRoute.exercise.path,
      name: AppRoute.exercise.name,
      pageBuilder: (context, state) {
        final extra = state.extra;
        return _page(
          AppRoute.exercise,
          ExercisePage(
            seedIds: extra is List<String> ? extra : const <String>[],
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoute.settings.path,
      name: AppRoute.settings.name,
      pageBuilder: (context, state) => _page(
        AppRoute.settings,
        const RoutePlaceholderPage(route: AppRoute.settings),
      ),
    ),
    GoRoute(
      path: AppRoute.signIn.path,
      name: AppRoute.signIn.name,
      pageBuilder: (context, state) => _page(AppRoute.signIn, const AuthPage()),
    ),
  ];

  /// Material page with a stable key derived from [route].
  static Page<void> _page(AppRoute route, Widget child) {
    return MaterialPage<void>(
      key: route.pageKey,
      name: route.name,
      child: child,
    );
  }
}
