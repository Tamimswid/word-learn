import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/design_system.dart';
import '../core/router/router.dart';

class WordlearnApp extends StatefulWidget {
  const WordlearnApp({super.key, this.router});

  /// Optional router override, mainly useful for tests and deep-link flows.
  /// When omitted, [AppRouter.create] is used.
  final GoRouter? router;

  @override
  State<WordlearnApp> createState() => _WordlearnAppState();
}

class _WordlearnAppState extends State<WordlearnApp> {
  late final GoRouter _router = widget.router ?? AppRouter.create();

  @override
  void dispose() {
    if (widget.router == null) _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kelime',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
