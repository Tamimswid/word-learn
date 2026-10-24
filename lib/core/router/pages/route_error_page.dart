import 'package:flutter/material.dart';

import '../../design_system/app_colors.dart';
import '../../design_system/app_spacing.dart';
import '../../design_system/app_typography.dart';
import '../../widgets/app_button.dart';
import '../app_navigation.dart';
import '../app_route.dart';

/// Shown by the router when no route matches the requested location.
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key, required this.location, this.message});

  final String location;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.explore_off_rounded,
                color: AppColors.mutedForeground,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sayfa bulunamadı',
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                message ?? location,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Ana sayfaya dön',
                icon: const Icon(Icons.home_rounded),
                onPressed: () => context.goTo(AppRoute.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
