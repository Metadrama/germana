import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';

/// Colored status badge chip — "2 seats left", "Disahkan", etc.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
  });

  factory StatusBadge.seats(int seatsLeft, {String? label}) {
    final Color bg;
    final Color fg;
    if (seatsLeft <= 1) {
      bg = AppColors.accentAmber.withValues(alpha: 0.15);
      fg = AppColors.accentAmber;
    } else {
      bg = AppColors.accentGreen.withValues(alpha: 0.12);
      fg = AppColors.accentGreen;
    }
    return StatusBadge(
      label: label ?? '$seatsLeft seats',
      color: bg,
      textColor: fg,
    );
  }

  factory StatusBadge.confirmed() {
    return StatusBadge(
      label: 'Disahkan',
      color: AppColors.accentGreen.withValues(alpha: 0.12),
      textColor: AppColors.accentGreen,
    );
  }

  factory StatusBadge.completed() {
    return StatusBadge(
      label: 'Selesai',
      color: AppColors.accentSky.withValues(alpha: 0.12),
      textColor: AppColors.accentSky,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? AppColors.accentBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(context).copyWith(
          color: textColor ?? AppColors.accentBlue,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
