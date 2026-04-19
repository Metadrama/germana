import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';

/// Subtle flat background wash with minimal gradient accents.
class AmbientBackground extends StatefulWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.background,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.background,
                colors.backgroundElevated.withValues(alpha: 0.94),
              ],
            ),
          ),
        ),
        Positioned(
          left: -120,
          top: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.blobViolet.withValues(alpha: colors.isDark ? 0.16 : 0.12),
            ),
          ),
        ),
        Positioned(
          right: -130,
          bottom: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.blobSky.withValues(alpha: colors.isDark ? 0.14 : 0.1),
            ),
          ),
        ),

        // App content on top
        widget.child,
      ],
    );
  }
}
