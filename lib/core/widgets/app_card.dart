import 'package:flutter/material.dart';

import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_shadows.dart';
import '../design_system/app_spacing.dart';

enum AppCardVariant { elevated, muted, outline }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.card),
    this.variant = AppCardVariant.elevated,
    this.onTap,
    this.highlighted = false,
    this.radius = AppRadius.xl,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final bool highlighted;
  final double radius;

  Color get _background => switch (variant) {
    AppCardVariant.elevated => AppColors.card,
    AppCardVariant.muted => AppColors.muted,
    AppCardVariant.outline => AppColors.transparent,
  };

  Color get _borderColor =>
      highlighted ? AppColors.primaryBorder : AppColors.border;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final decoration = BoxDecoration(
      color: _background,
      borderRadius: borderRadius,
      border: Border.all(color: _borderColor),
      boxShadow: variant == AppCardVariant.elevated ? AppShadows.card : null,
    );

    if (onTap == null) {
      return Container(decoration: decoration, padding: padding, child: child);
    }

    return DecoratedBox(
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: InkWell(
          onTap: onTap,
          overlayColor: const WidgetStatePropertyAll(AppColors.foregroundFaint),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
