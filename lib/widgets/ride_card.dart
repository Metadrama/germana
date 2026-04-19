import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/widgets/pill_button.dart';
import 'package:germana/widgets/price_breakdown_row.dart';
import 'package:germana/widgets/status_badge.dart';
import 'package:intl/intl.dart';

/// AFA-inspired ride listing card — glassmorphic, theme-aware.
class RideCard extends StatefulWidget {
  final RideModel ride;
  final VoidCallback? onTap;
  final VoidCallback? onSecureSeat;
  final double? distanceFromSearchKm;

  const RideCard({
    super.key,
    required this.ride,
    this.onTap,
    this.onSecureSeat,
    this.distanceFromSearchKm,
  });

  @override
  State<RideCard> createState() => _RideCardState();
}

class _RideCardState extends State<RideCard> {
  String _formatTime(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Departed';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}j ${diff.inMinutes % 60}m';
    return DateFormat('EEE, h:mm a').format(dt);
  }

  String _sexLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return widget.ride.driverSex == DriverSex.female ? l10n.sexFemale : l10n.sexMale;
  }

  DateTime _estimatedArrival() {
    final avgSpeedKmh = widget.ride.distanceKm < 8
        ? 24.0
        : widget.ride.distanceKm < 25
            ? 38.0
            : widget.ride.distanceKm < 80
                ? 60.0
                : 78.0;
    final minutes = (widget.ride.distanceKm / avgSpeedKmh * 60)
        .clamp(1, 24 * 60)
        .round();
    return widget.ride.departureTime.add(Duration(minutes: minutes));
  }

  String _timeLabel(DateTime time) => DateFormat('h:mm a').format(time);

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Material(
        type: MaterialType.transparency,
        child: GlassBox(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 140) {
                return Text(
                  '${widget.ride.origin} -> ${widget.ride.destination}',
                  style: AppTextStyles.caption(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 120) {
                            return Text(
                              '${widget.ride.origin} -> ${widget.ride.destination}',
                              style: AppTextStyles.headline(context),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            );
                          }

                          return Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accentBlue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${widget.ride.origin} -> ${widget.ride.destination}',
                                  style: AppTextStyles.headline(context),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: StatusBadge.seats(
                        widget.ride.seatsLeft,
                        label: widget.ride.seatsLeft == 1
                            ? '1 seat'
                            : '${widget.ride.seatsLeft} seats',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                // Car + departure info
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _metaItem(
                      context,
                      icon: Icons.directions_car_rounded,
                      label: widget.ride.carModel,
                    ),
                    _metaItem(
                      context,
                      icon: Icons.straighten_rounded,
                      label: '${widget.ride.distanceKm.toStringAsFixed(1)} km',
                    ),
                    _metaItem(
                      context,
                      icon: Icons.badge_outlined,
                      label: _sexLabel(context),
                    ),
                    _metaItem(
                      context,
                      icon: Icons.schedule_rounded,
                      label: '${l10n.departureTimeLabel}: ${_formatTime(widget.ride.departureTime)}',
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                _routeTimeline(context),

                if (widget.distanceFromSearchKm != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.near_me_rounded,
                        size: 13,
                        color: AppColors.accentSky,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '~${widget.distanceFromSearchKm!.toStringAsFixed(1)} km to searched destination',
                        style: AppTextStyles.caption(context).copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 14),

                // Price + CTA row (responsive for narrow cards)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 420;

                    final priceInfo = Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'RM ${widget.ride.totalPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.price(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            l10n.perSeatPriceLabel,
                            style: AppTextStyles.caption(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );

                    final cta = PillButton(
                      label: 'Tempah',
                      isSmall: true,
                      onPressed: widget.onSecureSeat ?? widget.onTap,
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          priceInfo,
                          const SizedBox(height: 8),
                          Align(alignment: Alignment.centerRight, child: cta),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: priceInfo),
                        const SizedBox(width: 8),
                        cta,
                      ],
                    );
                  },
                ),

                const SizedBox(height: 8),

                PriceBreakdownRow(
                  fuelShare: widget.ride.fuelShare,
                  tollShare: widget.ride.tollShare,
                  platformFee: widget.ride.platformFee,
                ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _metaItem(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colors = GermanaColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.textSecondary.withValues(alpha: 0.9)),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption(context).copyWith(
            color: colors.textSecondary.withValues(alpha: 0.95),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _routeTimeline(BuildContext context) {
    final endTime = _timeLabel(_estimatedArrival());
    final startTime = _timeLabel(widget.ride.departureTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 32,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.accentBlue.withValues(alpha: 0.78),
                            AppColors.accentGreen.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentGreen.withValues(alpha: 0.12),
                        border: Border.all(color: AppColors.accentGreen, width: 2.2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    _routeTimelineRow(
                      context,
                      label: 'From',
                      value: widget.ride.pickupAddress,
                      timeText: startTime,
                      emphasize: true,
                    ),
                    const SizedBox(height: 10),
                    _routeTimelineRow(
                      context,
                      label: 'To',
                      value: widget.ride.destination,
                      timeText: endTime,
                      emphasize: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _routeTimelineRow(
    BuildContext context, {
    required String label,
    required String value,
    required String timeText,
    required bool emphasize,
  }) {
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
                  color: colors.isDark
                      ? colors.textSecondary.withValues(alpha: 0.92)
                      : colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: (emphasize ? AppTextStyles.headline(context) : AppTextStyles.body(context)).copyWith(
                  fontSize: emphasize ? 14 : 13,
                  color: emphasize
                      ? colors.textPrimary
                      : colors.textPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          timeText,
          style: AppTextStyles.captionBold(context).copyWith(
            color: emphasize
                ? AppColors.accentBlue
                : colors.isDark
                    ? colors.textSecondary.withValues(alpha: 0.9)
                    : colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
