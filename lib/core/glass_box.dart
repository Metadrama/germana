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
    this.blur = 10,
    this.opacity = 0.92,
    this.borderRadius = 20,
    this.tint,
    this.padding,
    this.margin,
    this.borderWidth = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);

    // Flat, readable glass plate: consistent tint + subtle edge, no heavy effects.
    final effectiveTint = tint ?? colors.glassSurface;
    final effectiveOpacity = opacity.clamp(0.0, 1.0);
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
