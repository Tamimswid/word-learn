import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/app_assets.dart';
import '../../../../core/widgets/app_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// The single call-to-action on the sign-in screen.
class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) => previous.isBusy != current.isBusy,
      builder: (context, state) {
        final isBusy = state.isBusy;

        return AppButton(
          label: 'Sign in',
          semanticLabel: 'Google ile giriş yap',
          icon: Image.asset(
            AppAssets.google,
            width: 18,
            height: 18,
            filterQuality: FilterQuality.high,
          ),
          variant: AppButtonVariant.light,
          isLoading: isBusy,
          expanded: true,
          size: AppButtonSize.large,
          onPressed: isBusy
              ? null
              : () => context.read<AuthCubit>().signInWithGoogle(),
        );
      },
    );
  }
}
