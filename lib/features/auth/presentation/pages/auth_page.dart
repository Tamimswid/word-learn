import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/app_locator.dart';
import '../cubit/auth_cubit.dart';
import '../widget/auth_content.dart';

/// Route entry for the authentication screen.
///
/// The shared [AuthCubit] is taken from the existing service locator and
/// provided above the page so every state-aware widget reads the same
/// instance.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: locator<AuthCubit>(),
      child: const AuthContent(),
    );
  }
}
