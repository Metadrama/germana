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
      isDark ? const Color(0xFF0A0E1A) : const Color(0xFFF0F4FF);
  Color get backgroundElevated =>
      isDark ? const Color(0xFF141829) : const Color(0xFFE8ECF7);

  // Glass
  Color get glassSurface => isDark
      ? const Color(0x33FFFFFF) // 20% white on dark
      : const Color(0x73FFFFFF); // 45% white on light
  Color get glassBorder => isDark
      ? const Color(0x26FFFFFF) // 15% white
      : const Color(0xB3FFFFFF); // 70% white
  Color get glassBorderSubtle => isDark
      ? const Color(0x13FFFFFF) // 7%
      : const Color(0x4DFFFFFF); // 30%

  // Text
  Color get textPrimary =>
      isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1C1C1E);
  Color get textSecondary =>
      isDark ? const Color(0xFF98989D) : const Color(0xFF6E6E73);
  Color get textTertiary =>
      isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93);

  // Ambient blobs
  Color get blobViolet => isDark
      ? const Color(0x338B5CF6) // deeper violet, lower opacity
      : const Color(0x59C4A6FF);
  Color get blobSky => isDark
      ? const Color(0x2B0EA5E9) // deeper sky
      : const Color(0x4D85DAFF);

  // Dividers
  Color get divider =>
      isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000);

  // Nav bar
  Color get navSurface => isDark
      ? const Color(0x4D1C1C1E)
      : const Color(0x8CFFFFFF);
  Color get navBorder => isDark
      ? const Color(0x1AFFFFFF)
      : const Color(0xB3FFFFFF);

  // Card fill (for non-glass elements)
  Color get cardFill => isDark
      ? const Color(0xFF1C2033)
      : Colors.white;
}

// ─────────────────────────────────────────────
//  STATIC ACCENT COLORS — same in both modes
// ─────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Accent
  static const Color accentBlue = Color(0xFF007AFF);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentSky = Color(0xFF5AC8FA);
  static const Color accentAmber = Color(0xFFFF9F0A);
  static const Color accentRed = Color(0xFFFF3B30);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // TnG Green — Malaysia specific
  static const Color tngBlue = Color(0xFF005ABB);

  // Semantic
  static const Color escrowBlue = Color(0xFF007AFF);
  static const Color releasedGreen = Color(0xFF34C759);
  static const Color refundAmber = Color(0xFFFF9F0A);
  static const Color feeNeutral = Color(0xFFC7C7CC);
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
  static const double heavy = 24.0;
  static const double medium = 16.0;
  static const double subtle = 12.0;
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
      fontSize: 15, fontWeight: FontWeight.w400, color: c.textSecondary,
    );
  }

  static TextStyle caption(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w500, color: c.textSecondary,
    );
  }

  static TextStyle captionBold(BuildContext context) {
    final c = GermanaColors.of(context);
    return GoogleFonts.plusJakartaSans(
      fontSize: 12, fontWeight: FontWeight.w600, color: c.textPrimary,
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
      surface: Color(0xFFF0F4FF),
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
      secondary: AppColors.accentSky,
      surface: Color(0xFF0A0E1A),
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
