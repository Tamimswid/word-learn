import 'package:flutter/material.dart';

import '../design_system/app_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger, success, light }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expanded = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool expanded;
  final String? semanticLabel;

  bool get _isDisabled => onPressed == null;

  Color get _background => switch (variant) {
    AppButtonVariant.primary => AppColors.primary,
    AppButtonVariant.secondary => AppColors.foregroundFaint,
    AppButtonVariant.ghost => AppColors.transparent,
    AppButtonVariant.danger => AppColors.destructive,
    AppButtonVariant.success => AppColors.successSoft,
    AppButtonVariant.light => AppColors.foreground,
  };

  Color get _foreground => switch (variant) {
    AppButtonVariant.primary => AppColors.onPrimary,
    AppButtonVariant.secondary => AppColors.foreground,
    AppButtonVariant.ghost => AppColors.secondaryForeground,
    AppButtonVariant.danger => AppColors.onPrimary,
    AppButtonVariant.success => AppColors.success,
    AppButtonVariant.light => AppColors.background,
  };

  Color get _borderColor => switch (variant) {
    AppButtonVariant.secondary => AppColors.border,
    AppButtonVariant.danger => AppColors.destructiveBorder,
    AppButtonVariant.success => AppColors.successBorder,
    AppButtonVariant.primary || AppButtonVariant.ghost || AppButtonVariant.light => AppColors.transparent,
  };

  Color get _overlayColor =>
      variant == AppButtonVariant.light ? AppColors.background.withValues(alpha: 0.08) : AppColors.foregroundFaint;

  double get _height => switch (size) {
    AppButtonSize.small => 36,
    AppButtonSize.medium => 44,
    AppButtonSize.large => 48,
  };

  double get _horizontalPadding => switch (size) {
    AppButtonSize.small => AppSpacing.md,
    AppButtonSize.medium => AppSpacing.lg,
    AppButtonSize.large => AppSpacing.xl,
  };

  double get _radius => switch (size) {
    AppButtonSize.small => AppRadius.sm,
    _ => AppRadius.md,
  };

  double get _iconSize => switch (size) {
    AppButtonSize.small => 14,
    AppButtonSize.medium => 16,
    AppButtonSize.large => 18,
  };

  TextStyle get _textStyle => switch (size) {
    AppButtonSize.small => AppTypography.labelMedium,
    AppButtonSize.medium => AppTypography.labelLarge,
    AppButtonSize.large => AppTypography.titleSmall,
  };

  @override
  Widget build(BuildContext context) {
    final canTap = !_isDisabled && !isLoading;
    final iconTheme = IconThemeData(color: _foreground, size: _iconSize);

    return Semantics(
      button: true,
      enabled: !_isDisabled,
      label: semanticLabel ?? label,
      child: ExcludeSemantics(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _isDisabled ? 0.5 : 1,
          child: SizedBox(
            width: expanded ? double.infinity : null,
            height: _height,
            child: Material(
              color: _background,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_radius),
                side: BorderSide(color: _borderColor),
              ),
              child: InkWell(
                onTap: canTap ? onPressed : null,
                overlayColor: WidgetStatePropertyAll(_overlayColor),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLoading) ...[
                        SizedBox(
                          width: _iconSize,
                          height: _iconSize,
                          child: CircularProgressIndicator(strokeWidth: 2, color: _foreground),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ] else if (icon != null) ...[
                        IconTheme(data: iconTheme, child: icon!),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _textStyle.copyWith(color: _foreground),
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        IconTheme(data: iconTheme, child: trailingIcon!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AppIconButtonVariant { secondary, ghost, outline, primary }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.variant = AppIconButtonVariant.secondary,
    this.size = 30,
    this.isSelected = false,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final AppIconButtonVariant variant;
  final double size;
  final bool isSelected;

  Color get _background {
    if (isSelected) return AppColors.primarySoft;
    return switch (variant) {
      AppIconButtonVariant.secondary => AppColors.secondary,
      AppIconButtonVariant.ghost => AppColors.transparent,
      AppIconButtonVariant.outline => AppColors.transparent,
      AppIconButtonVariant.primary => AppColors.primary,
    };
  }

  Color get _foreground {
    if (isSelected) return AppColors.primaryGlow;
    return switch (variant) {
      AppIconButtonVariant.secondary => AppColors.secondaryForeground,
      AppIconButtonVariant.ghost => AppColors.mutedForeground,
      AppIconButtonVariant.outline => AppColors.secondaryForeground,
      AppIconButtonVariant.primary => AppColors.onPrimary,
    };
  }

  Color get _borderColor {
    if (isSelected) return AppColors.primaryBorder;
    return switch (variant) {
      AppIconButtonVariant.outline => AppColors.border,
      _ => AppColors.transparent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final button = Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: Material(
            color: _background,
            clipBehavior: Clip.antiAlias,
            shape: CircleBorder(side: BorderSide(color: _borderColor)),
            child: InkWell(
              onTap: onPressed,
              overlayColor: const WidgetStatePropertyAll(AppColors.foregroundFaint),
              child: IconTheme(
                data: IconThemeData(color: _foreground, size: size * 0.5),
                child: Center(child: icon),
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip == null) return button;

    return Tooltip(message: tooltip!, child: button);
  }
}
