import 'package:flutter/material.dart';

import '../../design_system/app_assets.dart';
import '../../design_system/app_colors.dart';
import '../../design_system/app_gradients.dart';
import '../../design_system/app_spacing.dart';
import '../../design_system/app_typography.dart';

/// Shown while the app restores the session before routing to auth or home.
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          gradient: AppGradients.glow,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRect(
                  child: SizedBox(
                    width: 180,
                    height: 84,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.asset(
                        AppAssets.loader,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Yükleniyor…',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
