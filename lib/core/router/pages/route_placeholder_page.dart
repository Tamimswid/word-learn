import 'package:flutter/material.dart';

import '../../design_system/app_colors.dart';
import '../../design_system/app_spacing.dart';
import '../../design_system/app_typography.dart';
import '../app_route.dart';

/// Temporary page for routes whose feature screen has not landed yet.
///
/// Replace the placeholder in [AppRouter] as each feature screen is built.
class RoutePlaceholderPage extends StatelessWidget {
  const RoutePlaceholderPage({
    super.key,
    required this.route,
    this.pathParameters = const <String, String>{},
  });

  final AppRoute route;
  final Map<String, String> pathParameters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(route.name)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.construction_rounded,
                  color: AppColors.mutedForeground,
                  size: 40,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bu ekran hazırlanıyor',
                  style: AppTypography.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  route.path,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (pathParameters.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    pathParameters.entries
                        .map((entry) => '${entry.key}: ${entry.value}')
                        .join('\n'),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondaryForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
