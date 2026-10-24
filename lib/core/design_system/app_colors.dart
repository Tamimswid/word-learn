import 'package:flutter/material.dart';

/// Color tokens extracted from the Kelime design system.
///
/// The palette is dark-first and built for high contrast on OLED screens.
abstract final class AppColors {
  // Canvas & surfaces
  static const Color canvas = Color(0xFF020203);
  static const Color background = Color(0xFF070708);
  static const Color card = Color(0xFF17181A);
  static const Color muted = Color(0xFF111213);
  static const Color secondary = Color(0xFF262629);
  static const Color overlay = Color(0xB3000000);

  // Text
  static const Color foreground = Color(0xFFF5F7F7);
  static const Color secondaryForeground = Color(0xFFD1D8E1);
  static const Color mutedForeground = Color(0xFF878D94);
  static const Color onPrimary = Color(0xFFFCFCFC);

  // Brand
  static const Color primary = Color(0xFF5D69CB);
  static const Color primaryGlow = Color(0xFF7978FB);

  // Feedback
  static const Color success = Color(0xFF2EA957);
  static const Color onSuccess = Color(0xFFFCFCFC);
  static const Color destructive = Color(0xFFEC5258);
  static const Color onDestructive = Color(0xFFFCFCFC);

  // Borders
  static const Color border = Color(0x14FFFFFF);
  static const Color borderStrong = Color(0x33FFFFFF);
  static const Color input = Color(0x14FFFFFF);

  // Tints (design uses color-mix on base tokens)
  static const Color primarySoft = Color(0x265D69CB);
  static const Color primaryBar = Color(0x595D69CB);
  static const Color primaryBorder = Color(0x4D5D69CB);
  static const Color successSoft = Color(0x262EA957);
  static const Color successBorder = Color(0x4D2EA957);
  static const Color destructiveSoft = Color(0x1AEC5258);
  static const Color destructiveBorder = Color(0x4DEC5258);
  static const Color foregroundFaint = Color(0x0AF5F7F7);
  static const Color foregroundDisabled = Color(0x66F5F7F7);

  // Elevation
  static const Color shadow = Color(0xCC000000);

  static const Color transparent = Colors.transparent;
}
