import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale extracted from the design, rendered with the Tajawal family.
///
/// Tajawal is a static-weight Arabic family, so weights are expressed with
/// [FontWeight] instead of variable-font axes.
abstract final class AppTypography {
  static String get fontFamily => GoogleFonts.tajawal().fontFamily!;

  static TextStyle get displayLarge => GoogleFonts.tajawal(
    fontSize: 40,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -1,
  );

  static TextStyle get displayMedium => GoogleFonts.tajawal(
    fontSize: 38,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -0.8,
  );

  static TextStyle get headingLarge => GoogleFonts.tajawal(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static TextStyle get headingMedium => GoogleFonts.tajawal(
    fontSize: 25,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get headingSmall => GoogleFonts.tajawal(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static TextStyle get titleLarge => GoogleFonts.tajawal(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: -0.24,
  );

  static TextStyle get titleMedium => GoogleFonts.tajawal(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static TextStyle get titleSmall => GoogleFonts.tajawal(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle get bodyLarge => GoogleFonts.tajawal(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.tajawal(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.tajawal(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get labelLarge => GoogleFonts.tajawal(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static TextStyle get labelMedium => GoogleFonts.tajawal(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static TextStyle get labelSmall => GoogleFonts.tajawal(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static TextStyle get caption => GoogleFonts.tajawal(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static TextStyle get overline => GoogleFonts.tajawal(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.5,
  );
}
