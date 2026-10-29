import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordlearn/core/widgets/app_animated_background.dart';

import '../../../../core/design_system/design_system.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'auth_google_button.dart';
import 'auth_word_cards.dart';

/// Minimal sign-in screen: introduction, rotating word cards and one action.
class AuthContent extends StatelessWidget {
  const AuthContent({super.key});

  static const String _body = 'سجل دخولك وابنِ مفرداتك الإنجليزية بأسلوب بسيط وممتع.';

  /// Share of the screen height the card deck occupies.
  static const double _cardsHeightFraction = 0.45;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppAnimatedBackground(
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height:
                                MediaQuery.sizeOf(context).height *
                                _cardsHeightFraction,
                            child: const AuthWordCards(),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            _body,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
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
