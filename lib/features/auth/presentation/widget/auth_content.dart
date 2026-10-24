import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'auth_google_button.dart';
import 'auth_hero.dart';

/// Minimal sign-in screen: introduction, floating illustration and one action.
class AuthContent extends StatelessWidget {
  const AuthContent({super.key});

  static const String _title = 'ابدأ رحلة التعلم';
  static const String _body = 'سجل دخولك وابنِ مفرداتك الإنجليزية بأسلوب بسيط وممتع.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.glow),
        child: SafeArea(
          child: BlocListener<AuthCubit, AuthState>(
            listenWhen: (previous, current) => current.hasError && previous.failure != current.failure,
            listener: (context, state) {
              final message = state.errorMessage;
              if (message == null) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Spacer(flex: 1),
                          Text(
                            _title,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: AppTypography.headingLarge.copyWith(color: AppColors.foreground),
                          ),
                          Spacer(flex: 3),
                          const SizedBox(height: 320, child: AuthHero()),
                          Spacer(flex: 1),

                          Text(
                            _body,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.mutedForeground),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 420, child: AuthGoogleButton()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
