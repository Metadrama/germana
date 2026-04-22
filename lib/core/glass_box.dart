import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';

/// Clean, standard card/container that stops abusing the heavy glass blur for
/// standard inline content, creating a cleaner, more legible UI.
/// For true floating glass (like navbars or sticky headers), you should use higher blur
/// and deeper translucency manually.
class GlassBox extends StatelessWidget {
  final Widget? child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Color? tint;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderWidth;
  final bool isSolid;

  const GlassBox({
    super.key,
    this.child,
    this.blur = 30, // Increased blur for when it *is* used as glass
    this.opacity = -1, // -1 means auto-determine from theme.dart
    this.borderRadius = 20,
    this.tint,
    this.padding,
    this.margin,
    this.borderWidth = 0.5,
    this.isSolid = true, // By default, let's make most boxes solid and clean
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);

    // If it's just a regular content card, render a clean solid surface
    if (isSolid) {
      return Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardFill,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: colors.divider,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: child,
      );
    }

    // High-quality true liquid glass for floating elements
    final effectiveTint = tint ?? colors.glassSurface;
    final defaultOpacity = colors.isDark ? 0.25 : 0.4;
    final effectiveOpacity = opacity == -1 ? defaultOpacity : opacity.clamp(0.0, 1.0);
    final borderColor = colors.glassBorderSubtle;

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: effectiveTint.withValues(alpha: effectiveOpacity),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

