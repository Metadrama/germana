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
class RideCard extends StatelessWidget {
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

  String _formatTime(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Sudah lepas';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}j ${diff.inMinutes % 60}m';
    return DateFormat('EEE, h:mm a').format(dt);
  }

  String _sexLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ride.driverSex == DriverSex.female ? l10n.sexFemale : l10n.sexMale;
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Material(
        type: MaterialType.transparency,
        child: GlassBox(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 140) {
                return Text(
                  '${ride.origin} -> ${ride.destination}',
                  style: AppTextStyles.caption(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Route row (switch to text-only on ultra narrow widths)
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 120) {
                      return Text(
                        '${ride.origin} -> ${ride.destination}',
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
                            '${ride.origin} -> ${ride.destination}',
                            style: AppTextStyles.headline(context),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge.seats(ride.seatsLeft),
                ),

                const SizedBox(height: 8),

                // Car + departure info
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _metaItem(
                      context,
                      icon: Icons.directions_car_rounded,
                      label: ride.carModel,
                    ),
                    _metaItem(
                      context,
                      icon: Icons.straighten_rounded,
                      label: '${ride.distanceKm.toStringAsFixed(1)} km',
                    ),
                    _metaItem(
                      context,
                      icon: Icons.badge_outlined,
                      label: _sexLabel(context),
                    ),
                    _metaItem(
                      context,
                      icon: Icons.schedule_rounded,
                      label: '${l10n.departureTimeLabel}: ${_formatTime(ride.departureTime)}',
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.pin_drop_outlined,
                        size: 14, color: colors.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Pickup: ${ride.pickupAddress}',
                        style: AppTextStyles.caption(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (distanceFromSearchKm != null) ...[
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
                        '~${distanceFromSearchKm!.toStringAsFixed(1)} km to searched destination',
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
                          'RM ${ride.totalPrice.toStringAsFixed(2)}',
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
                      onPressed: onSecureSeat ?? onTap,
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

                const SizedBox(height: 10),

                  PriceBreakdownRow(
                    fuelShare: ride.fuelShare,
                    tollShare: ride.tollShare,
                    platformFee: ride.platformFee,
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
        Icon(icon, size: 14, color: colors.textTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption(context),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
