import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/app_locator.dart';
import '../core/router/app_route.dart';
import '../core/router/app_router.dart';
import '../features/auth/auth.dart';
import 'app.dart';

/// Provides the shared auth cubit and auth-aware router to the app.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  final AuthCubit _authCubit = locator<AuthCubit>();

  late final _AuthStreamRefresh _refresh = _AuthStreamRefresh(
    _authCubit.stream,
  );

  late final GoRouter _router = AppRouter.create(
    initialLocation: AppRoute.loading.path,
    refreshListenable: _refresh,
    redirect: _redirect,
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final auth = _authCubit.state;
    final onLoading = state.matchedLocation == AppRoute.loading.path;
    final onSignIn = state.matchedLocation == AppRoute.signIn.path;

    if (auth.isInitializing && !auth.hasError) {
      return onLoading ? null : AppRoute.loading.path;
    }

    if (auth.isInitializing) {
      return onSignIn ? null : AppRoute.signIn.path;
    }

    if (!auth.isAuthenticated) {
      return onSignIn ? null : AppRoute.signIn.path;
    }

    return onSignIn || onLoading ? AppRoute.deck.path : null;
  }

  @override
  void dispose() {
    _refresh.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _authCubit,
      child: WordlearnApp(router: _router),
    );
  }
}

/// Turns a cubit stream into a [Listenable] for `GoRouter.refreshListenable`.
class _AuthStreamRefresh extends ChangeNotifier {
  _AuthStreamRefresh(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
