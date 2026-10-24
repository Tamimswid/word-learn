import 'package:flutter/widgets.dart';

/// Every navigable location in the app.
///
/// This enum is the single source of truth for route paths, route names and
/// page keys. Features must never hard-code a location string.
enum AppRoute {
  home(name: 'home', path: '/'),
  addWord(name: 'add-word', path: '/words/new'),
  wordDetail(name: 'word-detail', path: '/words/:wordId'),
  deck(name: 'deck', path: '/deck'),
  exercise(name: 'exercise', path: '/exercise'),
  settings(name: 'settings', path: '/settings'),
  signIn(name: 'sign-in', path: '/sign-in');

  const AppRoute({required this.name, required this.path});

  /// Unique route name used by `goNamed` / `pushNamed`.
  final String name;

  /// URL template. Segments starting with `:` are path parameters.
  final String path;

  /// Stable key handed to the [Page] created for this route.
  ValueKey<String> get pageKey => ValueKey<String>('page-$name');

  /// Whether [path] still contains an unfilled `:parameter`.
  bool get hasPathParameters => path.contains(':');

  /// Builds a concrete location by filling path parameters and appending
  /// query parameters.
  ///
  /// ```dart
  /// AppRoute.wordDetail.location(
  ///   pathParameters: {AppRouteParams.wordId: 'abc'},
  /// ); // /words/abc
  /// ```
  String location({
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
  }) {
    var resolved = path;
    for (final entry in pathParameters.entries) {
      resolved = resolved.replaceFirst(
        ':${entry.key}',
        Uri.encodeComponent(entry.value),
      );
    }

    final uri = Uri.parse(resolved);
    assert(
      !uri.path.contains(':'),
      'Missing path parameters for $path: $pathParameters',
    );
    if (queryParameters.isEmpty) return uri.toString();

    return uri
        .replace(
          queryParameters: <String, String>{
            ...uri.queryParameters,
            ...queryParameters,
          },
        )
        .toString();
  }
}

/// Names of the path parameters used by [AppRoute]s.
abstract final class AppRouteParams {
  static const String wordId = 'wordId';
}

/// Names of the query parameters used across the app.
abstract final class AppRouteQuery {
  /// Where the user came from, used to decide the back behaviour.
  static const String from = 'from';
}
