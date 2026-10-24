import 'package:flutter/material.dart';

import 'app_borders.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// The single source of truth for the app's dark, high-contrast theme.
abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryGlow,
      secondary: AppColors.primaryGlow,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: AppColors.secondary,
      onSecondaryContainer: AppColors.secondaryForeground,
      tertiary: AppColors.success,
      onTertiary: AppColors.onSuccess,
      error: AppColors.destructive,
      onError: AppColors.onDestructive,
      errorContainer: AppColors.destructiveSoft,
      onErrorContainer: AppColors.destructive,
      surface: AppColors.background,
      onSurface: AppColors.foreground,
      surfaceContainerLowest: AppColors.canvas,
      surfaceContainerLow: AppColors.muted,
      surfaceContainer: AppColors.card,
      surfaceContainerHigh: AppColors.card,
      surfaceContainerHighest: AppColors.secondary,
      onSurfaceVariant: AppColors.secondaryForeground,
      outline: AppColors.borderStrong,
      outlineVariant: AppColors.border,
      shadow: AppColors.shadow,
      scrim: AppColors.overlay,
      inverseSurface: AppColors.foreground,
      onInverseSurface: AppColors.background,
      inversePrimary: AppColors.primary,
      surfaceTint: AppColors.transparent,
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.foreground,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.foreground,
      ),
      displaySmall: AppTypography.headingLarge.copyWith(
        color: AppColors.foreground,
      ),
      headlineLarge: AppTypography.headingMedium.copyWith(
        color: AppColors.foreground,
      ),
      headlineMedium: AppTypography.headingSmall.copyWith(
        color: AppColors.foreground,
      ),
      headlineSmall: AppTypography.titleLarge.copyWith(
        color: AppColors.foreground,
      ),
      titleLarge: AppTypography.titleMedium.copyWith(
        color: AppColors.foreground,
      ),
      titleMedium: AppTypography.titleSmall.copyWith(
        color: AppColors.foreground,
      ),
      titleSmall: AppTypography.labelLarge.copyWith(
        color: AppColors.foreground,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.foreground),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: AppColors.foreground,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(
        color: AppColors.secondaryForeground,
      ),
      labelLarge: AppTypography.labelLarge.copyWith(
        color: AppColors.foreground,
      ),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.foreground,
      ),
      labelSmall: AppTypography.labelSmall.copyWith(
        color: AppColors.mutedForeground,
      ),
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      primaryColor: AppColors.primary,
      splashColor: AppColors.foregroundFaint,
      highlightColor: AppColors.foregroundFaint,
      hoverColor: AppColors.foregroundFaint,
      focusColor: AppColors.primarySoft,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleSmall.copyWith(
          color: AppColors.foreground,
        ),
        toolbarTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.foreground,
        ),
        iconTheme: const IconThemeData(color: AppColors.foreground, size: 20),
        actionsIconTheme: const IconThemeData(
          color: AppColors.secondaryForeground,
          size: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.shadow,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: AppBorders.side,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.secondary,
          disabledForegroundColor: AppColors.mutedForeground,
          shadowColor: AppColors.transparent,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: buttonShape,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.foregroundFaint,
          foregroundColor: AppColors.foreground,
          disabledForegroundColor: AppColors.mutedForeground,
          side: AppBorders.side,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: buttonShape,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGlow,
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          shape: buttonShape,
          textStyle: AppTypography.labelMedium,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.secondaryForeground,
          backgroundColor: AppColors.secondary,
          disabledForegroundColor: AppColors.mutedForeground,
          disabledBackgroundColor: AppColors.muted,
          highlightColor: AppColors.foregroundFaint,
          hoverColor: AppColors.foregroundFaint,
          iconSize: 18,
          minimumSize: const Size(36, 36),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.muted,
        isDense: true,
        constraints: const BoxConstraints(minHeight: 44),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.mutedForeground,
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.secondaryForeground,
        ),
        floatingLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.mutedForeground,
        ),
        errorStyle: AppTypography.caption.copyWith(
          color: AppColors.destructive,
        ),
        border: _outline(AppColors.border),
        enabledBorder: _outline(AppColors.border),
        focusedBorder: _outline(AppColors.primaryGlow),
        errorBorder: _outline(AppColors.destructive),
        focusedErrorBorder: _outline(AppColors.destructive),
        disabledBorder: _outline(AppColors.border),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        modalBackgroundColor: AppColors.card,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.shadow,
        modalBarrierColor: AppColors.overlay,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
        dragHandleColor: AppColors.borderStrong,
        dragHandleSize: Size(40, 4),
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.shadow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: AppBorders.side,
        ),
        titleTextStyle: AppTypography.titleMedium.copyWith(
          color: AppColors.foreground,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.mutedForeground,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondary,
        elevation: 0,
        contentTextStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.foreground,
        ),
        actionTextColor: AppColors.primaryGlow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: AppBorders.side,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primaryGlow,
        unselectedItemColor: AppColors.mutedForeground,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.overline,
        unselectedLabelStyle: AppTypography.overline,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.secondary,
        circularTrackColor: AppColors.secondary,
        linearMinHeight: 4,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primaryGlow,
        selectionColor: AppColors.primarySoft,
        selectionHandleColor: AppColors.primaryGlow,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        textStyle: AppTypography.caption.copyWith(color: AppColors.foreground),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        waitDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  static OutlineInputBorder _outline(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color),
    );
  }
}
