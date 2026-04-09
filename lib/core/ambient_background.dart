import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';

/// Animated ambient gradient background with drifting blobs.
/// Adapts blob colors to current theme brightness.
class AmbientBackground extends StatefulWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);

    return Stack(
      children: [
        // Base color
        Container(color: colors.background),

        // Animated blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final dx1 = math.sin(t * 2 * math.pi) * 20;
            final dy1 = math.cos(t * 2 * math.pi) * 15;
            final dx2 = math.cos(t * 2 * math.pi + 1) * 18;
            final dy2 = math.sin(t * 2 * math.pi + 1) * 22;

            return Stack(
              children: [
                // Violet blob — top left
                Positioned(
                  left: -60 + dx1,
                  top: -40 + dy1,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.blobViolet,
                          colors.blobViolet.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sky blob — bottom right
                Positioned(
                  right: -50 + dx2,
                  bottom: -30 + dy2,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.blobSky,
                          colors.blobSky.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Subtle tertiary glow — center
                Positioned(
                  left: MediaQuery.sizeOf(context).width * 0.3 + dx2 * 0.5,
                  top: MediaQuery.sizeOf(context).height * 0.4 + dy1 * 0.5,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentBlue.withValues(
                            alpha: colors.isDark ? 0.12 : 0.08,
                          ),
                          AppColors.accentBlue.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // App content on top
        widget.child,
      ],
    );
  }
}
