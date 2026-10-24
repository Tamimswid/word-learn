import 'package:flutter/widgets.dart';

/// App-wide [Key]s shared by widgets, navigation and tests.
///
/// Keeping them in one place avoids duplicated string literals and makes
/// widget tests resilient to UI refactors.
abstract final class AppKeys {
  // ---------------------------------------------------------------------------
  // Navigators
  // ---------------------------------------------------------------------------

  /// Root navigator owned by [GoRouter].
  static final GlobalKey<NavigatorState> rootNavigator =
      GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

  /// Reserved for the shell navigator that will host the bottom navigation.
  ///
  /// Use it as `parentNavigatorKey` when a page must be pushed above the shell
  /// (for example a full-screen exercise).
  static final GlobalKey<NavigatorState> shellNavigator =
      GlobalKey<NavigatorState>(debugLabel: 'shellNavigator');

  // ---------------------------------------------------------------------------
  // Shared widgets
  // ---------------------------------------------------------------------------

  static const ValueKey<String> appScaffold = ValueKey<String>('appScaffold');
  static const ValueKey<String> loadingIndicator = ValueKey<String>(
    'loadingIndicator',
  );
  static const ValueKey<String> emptyState = ValueKey<String>('emptyState');
  static const ValueKey<String> retryButton = ValueKey<String>('retryButton');
}
