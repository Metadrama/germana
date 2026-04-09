import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';

/// The atomic design unit of Germana.
/// Adapts glass tint, border, and shadow based on current theme brightness.
class GlassBox extends StatelessWidget {
  final Widget? child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Color? tint;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderWidth;

  const GlassBox({
    super.key,
    this.child,
    this.blur = 20,
    this.opacity = 0.45,
    this.borderRadius = 20,
    this.tint,
    this.padding,
    this.margin,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final isDark = colors.isDark;

    // In dark mode: tint is a subtle white overlay; in light: stronger white
    final effectiveTint = tint ?? (isDark ? Colors.white : Colors.white);
    final effectiveOpacity = isDark ? (opacity * 0.4).clamp(0.0, 1.0) : opacity;
    final borderColor = colors.glassBorder;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.06);

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
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
