import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Germana Design System — "Liquid Glass"
/// Apple-inspired translucent glass aesthetic with adaptive dark mode.
/// Every color resolves through [GermanaColors.of(context)] so all
/// widgets automatically adapt to the current brightness.

// ─────────────────────────────────────────────
//  RESOLVED COLORS — use GermanaColors.of(ctx)
// ─────────────────────────────────────────────

class GermanaColors {
  final Brightness brightness;

  const GermanaColors._(this.brightness);

  factory GermanaColors.of(BuildContext context) {
    return GermanaColors._(Theme.of(context).brightness);
  }

  bool get isDark => brightness == Brightness.dark;

  // Backgrounds
  Color get background =>
      isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
  Color get backgroundElevated =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);

  // Glass - High blur, low opacity
  Color get glassSurface => isDark
      ? const Color(0x28000000)
      : const Color(0x38FFFFFF);
  Color get glassBorder => isDark
      ? const Color(0x15FFFFFF)
      : const Color(0x1A000000);
  Color get glassBorderSubtle => isDark
      ? const Color(0x0AFFFFFF)
      : const Color(0x0A000000);

  // Text
  Color get textPrimary =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  Color get textSecondary =>
      isDark ? const Color(0x99EBEBF5) : const Color(0x993C3C43);
  Color get textTertiary =>
      isDark ? const Color(0x4DEBEBF5) : const Color(0x4D3C3C43);

  // Ambient blobs
  Color get blobViolet => isDark
      ? const Color(0x405E5CE6)
      : const Color(0x205856D6);
  Color get blobSky => isDark
      ? const Color(0x3064D2FF)
      : const Color(0x185AC8FA);

  // Dividers
  Color get divider =>
      isDark ? const Color(0x33545458) : const Color(0x2E3C3C43);

  // Nav bar
  Color get navSurface => isDark
      ? const Color(0x551C1C1E)
      : const Color(0x88F2F2F7);
  Color get navBorder => isDark
      ? const Color(0x1AFFFFFF)
      : const Color(0x1A000000);

  // Card fill (for non-glass elements)
  Color get cardFill => isDark
      ? const Color(0xFF1C1C1E)
      : const Color(0xFFFFFFFF);
}

// ─────────────────────────────────────────────
//  STATIC ACCENT COLORS — same in both modes
// ─────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Accent
  static const Color accentBlue = Color(0xFF0A84FF);
  static const Color accentGreen = Color(0xFF30D158);
  static const Color accentSky = Color(0xFF64D2FF);
  static const Color accentAmber = Color(0xFFFF9F0A);
  static const Color accentRed = Color(0xFFFF453A);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Route visual semantics
  static const Color routeStartBlue = Color(0xFF0A84FF);
  static const Color routeEndBlue = Color(0xFF0A84FF);
  static const Color routeStartRed = Color(0xFFFF453A);
  static const Color routeEndNeutralDark = Color(0xFF8E8E93);
  static const Color routeEndNeutralLight = Color(0xFF8E8E93);

  // TnG Green — Malaysia specific
  static const Color tngBlue = Color(0xFF005ABB);

  // Semantic
  static const Color escrowBlue = Color(0xFF0A84FF);
  static const Color releasedGreen = Color(0xFF30D158);
  static const Color refundAmber = Color(0xFFFF9F0A);
  static const Color feeNeutral = Color(0xFF8E8E93);
}

// ─────────────────────────────────────────────
//  SPACING & RADIUS
// ─────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();
  static const double chip = 12;
  static const double card = 20;
  static const double pill = 40;
}

class AppBlur {
  AppBlur._();
  static const double heavy = 40.0;
  static const double medium = 24.0;
  static const double subtle = 16.0;
}

// ─────────────────────────────────────────────
//  CONTEXT-AWARE TEXT STYLES
// ─────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 34, fontWeight: FontWeight.w700,
      color: c.textPrimary, letterSpacing: -0.5,
    );
  }

  static TextStyle title(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 22, fontWeight: FontWeight.w600,
      color: c.textPrimary, letterSpacing: -0.3,
    );
  }

  static TextStyle headline(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 17, fontWeight: FontWeight.w600, color: c.textPrimary,
    );
  }

  static TextStyle body(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 17, fontWeight: FontWeight.w400, color: c.textPrimary,
    );
  }

  static TextStyle bodySecondary(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 15, fontWeight: FontWeight.w500, color: c.textSecondary,
    );
  }

  static TextStyle caption(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 13, fontWeight: FontWeight.w500, color: c.textSecondary,
    );
  }

  static TextStyle captionBold(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary,
    );
  }

  static TextStyle price(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 20, fontWeight: FontWeight.w700,
      color: c.textPrimary, letterSpacing: -0.3,
    );
  }

  static TextStyle priceLarge(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 48, fontWeight: FontWeight.w700,
      color: c.textPrimary, letterSpacing: -1.0,
    );
  }

  static TextStyle wordmark(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 28, fontWeight: FontWeight.w700,
      color: c.textPrimary, letterSpacing: -0.8,
    );
  }
}

// ─────────────────────────────────────────────
//  THEME DATA BUILDERS
// ─────────────────────────────────────────────

ThemeData buildGermanaLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accentBlue,
      secondary: AppColors.accentSky,
      surface: Color(0xFFF2F2F7),
      error: AppColors.accentRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
  );
}

ThemeData buildGermanaDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentBlue,
      secondary: AppColors.accentBlue,
      surface: Color(0xFF000000),
      error: AppColors.accentRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
  );
}
