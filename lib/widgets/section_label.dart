import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';

/// Section header label — consistent styling, theme-aware.
class SectionLabel extends StatelessWidget {
  final String label;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const SectionLabel({
    super.key,
    required this.label,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.headline(context)),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(trailing!, style: AppTextStyles.caption(context).copyWith(
                color: AppColors.accentBlue,
              )),
            ),
        ],
      ),
    );
  }
}
