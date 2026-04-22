import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';

/// Frosted glass text input field — adaptive to theme brightness.
class GlassTextField extends StatelessWidget {
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final int maxLines;

  const GlassTextField({
    super.key,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.onSuffixTap,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: colors.isDark
                ? colors.backgroundElevated.withValues(alpha: 0.72)
                : colors.glassSurface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: colors.glassBorderSubtle,
              width: 0.9,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: AppTextStyles.body(context),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySecondary(context),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: colors.textSecondary, size: 20)
                  : null,
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixTap,
                      child: Icon(suffixIcon, color: colors.textSecondary, size: 20),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
