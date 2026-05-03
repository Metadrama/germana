/// Germana Design System
/// Material Design 3 + Selective Glassmorphism
/// Philosophy: Telegram Android 2026 approach
/// - Clean, consistent, modularized components
/// - Blur only on hero elements (navbar, modals, floating UI)
/// - Tonal elevation for depth (no shadows)
/// - 4dp base spacing grid

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  SPACING CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════
class GermanaSpacing {
  GermanaSpacing._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ═══════════════════════════════════════════════════════════════════════════
//  BORDER RADIUS CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════
class GermanaRadius {
  GermanaRadius._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 100.0;
}

// ═══════════════════════════════════════════════════════════════════════════
//  ELEVATION/SHADOW SYSTEM
// ═══════════════════════════════════════════════════════════════════════════
class GermanaShadows {
  GermanaShadows._();
  
  /// Subtle, barely visible shadow
  static List<BoxShadow> get xs => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  /// Light elevation (cards)
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Medium elevation (modals)
  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];
  
  /// Strong elevation (floating UI)
  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
//  BLUR CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════
class GermanaBlur {
  GermanaBlur._();
  
  /// Light blur for subtle glassmorphism
  static const double light = 8.0;
  
  /// Standard blur for navbar, modals (Telegram-style)
  static const double standard = 12.0;
  
  /// Heavy blur for strong glass effect (use sparingly)
  static const double heavy = 20.0;
}

// ═══════════════════════════════════════════════════════════════════════════
//  1. GERMANA CARD — Standard content container (solid, no blur)
// ═══════════════════════════════════════════════════════════════════════════
class GermanaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double borderRadius;
  final bool showBorder;
  final bool showShadow;

  const GermanaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius = 16,
    this.showBorder = true,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.cardFill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: colors.divider,
                width: 0.8,
              )
            : null,
        boxShadow: showShadow ? GermanaShadows.sm : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  2. GLASS SURFACE — Floating element with blur (navbar, modals, etc.)
// ═══════════════════════════════════════════════════════════════════════════
class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final bool showBorder;
  final bool showShadow;
  final Color? tintColor;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.blur = GermanaBlur.standard,
    this.showBorder = true,
    this.showShadow = true,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final isDark = colors.isDark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          margin: margin,
          decoration: BoxDecoration(
            color: tintColor ??
                (isDark
                    ? const Color(0xFF2A2A2D).withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.75)),
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 1,
                  )
                : null,
            boxShadow: showShadow ? GermanaShadows.md : null,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  3. ELEVATED SURFACE — Tonal depth without blur (Material Design 3)
// ═══════════════════════════════════════════════════════════════════════════
class ElevatedSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final int elevation;
  final bool showBorder;

  const ElevatedSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12,
    this.elevation = 1,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    
    // Tonal elevation: shift color based on elevation level
    final Color elevatedColor = _getTonalColor(colors, elevation);
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: elevatedColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: colors.divider.withValues(alpha: 0.5),
                width: 0.5,
              )
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Color _getTonalColor(GermanaColors colors, int elevation) {
    // Lightens in light mode, darkens in dark mode
    if (colors.isDark) {
      return colors.backgroundElevated.withValues(alpha: 0.3 * elevation);
    } else {
      return colors.background.withValues(alpha: 0.2 * elevation);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  4. INFO BANNER — Status messages (success, error, warning, info)
// ═══════════════════════════════════════════════════════════════════════════
class InfoBanner extends StatelessWidget {
  final String message;
  final InfoBannerType type;
  final IconData? icon;
  final VoidCallback? onDismiss;

  const InfoBanner({
    super.key,
    required this.message,
    this.type = InfoBannerType.info,
    this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final (bgColor, fgColor, defaultIcon) = _getColors(type);
    
    return GermanaCard(
      backgroundColor: bgColor.withValues(alpha: 0.12),
      borderRadius: 12,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon ?? defaultIcon, size: 18, color: fgColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: fgColor,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, size: 16, color: fgColor),
            ),
          ],
        ],
      ),
    );
  }

  (Color, Color, IconData) _getColors(InfoBannerType type) {
    switch (type) {
      case InfoBannerType.success:
        return (
          AppColors.accentGreen,
          AppColors.accentGreen,
          Icons.check_circle_outline_rounded,
        );
      case InfoBannerType.error:
        return (
          AppColors.accentRed,
          AppColors.accentRed,
          Icons.error_outline_rounded,
        );
      case InfoBannerType.warning:
        return (
          AppColors.accentAmber,
          AppColors.accentAmber,
          Icons.warning_rounded,
        );
      case InfoBannerType.info:
        return (
          AppColors.accentBlue,
          AppColors.accentBlue,
          Icons.info_outlined,
        );
    }
  }
}

enum InfoBannerType { success, error, warning, info }

// ═══════════════════════════════════════════════════════════════════════════
//  5. DIVIDER — Clean separator
// ═══════════════════════════════════════════════════════════════════════════
class GermanaDivider extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? margin;

  const GermanaDivider({
    super.key,
    this.height = 1,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 12),
      height: height,
      color: colors.divider.withValues(alpha: 0.3),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  6. SECTION HEADER — Consistent section titles
// ═══════════════════════════════════════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
