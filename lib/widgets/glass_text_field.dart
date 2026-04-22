import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';

/// Clean, native-feeling text input field (similar to CupertinoSearchTextField).
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

    return Container(
      decoration: BoxDecoration(
        color: colors.isDark
            ? const Color(0xFF767680).withValues(alpha: 0.24)
            : const Color(0xFF767680).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10), // Native Cupertino radius
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: AppTextStyles.body(context),
        cursorColor: AppColors.accentBlue,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySecondary(context).copyWith(
            color: colors.isDark 
              ? const Color(0xFFEBEBF5).withValues(alpha: 0.6)
              : const Color(0xFF3C3C43).withValues(alpha: 0.6),
          ),
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
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }
}

