import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:intl/intl.dart';

class RouteTimelineCard extends StatelessWidget {
  final String originLabel;
  final String destinationLabel;
  final DateTime departureTime;
  final double distanceKm;
  final String? durationText;
  final DateTime? arrivalTime;
  final String? subtitle;

  const RouteTimelineCard({
    super.key,
    required this.originLabel,
    required this.destinationLabel,
    required this.departureTime,
    required this.distanceKm,
    this.durationText,
    this.arrivalTime,
    this.subtitle,
  });

  DateTime _estimatedArrival() {
    if (arrivalTime != null) return arrivalTime!;

    // Conservative blended speed estimate for UI-only timeline.
    final avgSpeedKmh = distanceKm < 8
        ? 24.0
        : distanceKm < 25
            ? 38.0
            : distanceKm < 80
                ? 60.0
                : 78.0;
    final minutes = (distanceKm / avgSpeedKmh * 60).clamp(1, 24 * 60).round();
    return departureTime.add(Duration(minutes: minutes));
  }

  String _estimatedDurationLabel() {
    if (durationText != null && durationText!.trim().isNotEmpty) {
      return durationText!;
    }

    final minutes = _estimatedArrival().difference(departureTime).inMinutes;
    if (minutes < 60) return '~$minutes min';
    final hours = minutes ~/ 60;
    final rem = minutes % 60;
    if (rem == 0) return '~${hours}h';
    return '~${hours}h ${rem}m';
  }

  String _timeLabel(DateTime time) => DateFormat('h:mm a').format(time);

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final startTime = _timeLabel(departureTime);
    final endTime = _timeLabel(_estimatedArrival());
    final endDotColor = colors.isDark
        ? AppColors.routeEndNeutralDark
        : AppColors.routeEndNeutralLight;

    return GlassBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: AppTextStyles.caption(context).copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 26,
                child: Column(
                  children: [
                    Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.routeStartBlue,
                        border: Border.all(
                          color: colors.isDark
                              ? Colors.white.withValues(alpha: 0.44)
                              : Colors.white.withValues(alpha: 0.75),
                          width: 0.9,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colors.textTertiary.withValues(alpha: 0.55),
                      ),
                    ),
                    _StopDot(
                      color: endDotColor,
                      size: 13,
                      innerOpacity: 0.18,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    _TimelineRow(
                      label: 'Start',
                      value: originLabel,
                      timeText: startTime,
                      emphasize: true,
                    ),
                    const SizedBox(height: 18),
                    _TimelineRow(
                      label: 'End',
                      value: destinationLabel,
                      timeText: endTime,
                      emphasize: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: colors.divider, height: 20),
          Row(
            children: [
              _InfoPill(
                icon: Icons.straighten_rounded,
                text: '${distanceKm.toStringAsFixed(1)} km',
              ),
              const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.schedule_rounded,
                text: _estimatedDurationLabel(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final String value;
  final String timeText;
  final bool emphasize;

  const _TimelineRow({
    required this.label,
    required this.value,
    required this.timeText,
    required this.emphasize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption(context).copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: (emphasize ? AppTextStyles.headline(context) : AppTextStyles.body(context)).copyWith(
                  fontSize: emphasize ? 15 : 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          timeText,
          style: AppTextStyles.captionBold(context).copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StopDot extends StatelessWidget {
  final Color color;
  final double size;
  final double innerOpacity;

  const _StopDot({
    required this.color,
    required this.size,
    required this.innerOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: innerOpacity),
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.isDark
            ? colors.backgroundElevated.withValues(alpha: 0.72)
            : colors.glassSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: colors.glassBorderSubtle, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.accentBlue),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.caption(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
