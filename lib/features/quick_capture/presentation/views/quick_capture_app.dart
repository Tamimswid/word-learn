import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/app_locator.dart';
import '../cubit/quick_capture_cubit.dart';
import '../quick_capture_coordinator.dart';
import 'quick_capture_overlay.dart';

/// Root widget of the Android capture dialog.
///
/// It is launched from `quickCaptureMain`, so the router, home and the rest of
/// the app are never built for a capture.
class QuickCaptureApp extends StatefulWidget {
  const QuickCaptureApp({super.key});

  @override
  State<QuickCaptureApp> createState() => _QuickCaptureAppState();
}

class _QuickCaptureAppState extends State<QuickCaptureApp> {
  @override
  void initState() {
    super.initState();
    unawaited(locator<QuickCaptureCoordinator>().runSharedCapture());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuickCaptureCubit>.value(
      value: locator<QuickCaptureCubit>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        color: AppColors.transparent,
        theme: AppTheme.dark,
        home: const QuickCaptureOverlay(),
      ),
    );
  }
}
