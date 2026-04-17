import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
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

  const RideCard({
    super.key,
    required this.ride,
    this.onTap,
    this.onSecureSeat,
  });

  String _formatTime(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Sudah lepas';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}j ${diff.inMinutes % 60}m';
    return DateFormat('EEE, h:mm a').format(dt);
  }

  String _sexLabel() {
    return ride.driverSex == DriverSex.female ? 'Perempuan' : 'Lelaki';
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'ride_${ride.id}',
        child: Material(
          type: MaterialType.transparency,
          child: GlassBox(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route row
                Row(
                  children: [
                    Expanded(
                      child: Row(
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
                          Flexible(
                            child: Text(
                              ride.origin,
                              style: AppTextStyles.headline(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: colors.textTertiary,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              ride.destination,
                              style: AppTextStyles.headline(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge.seats(ride.seatsLeft),
                  ],
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
                      label: _sexLabel(),
                    ),
                    _metaItem(
                      context,
                      icon: Icons.schedule_rounded,
                      label: 'Masa: ${_formatTime(ride.departureTime)}',
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

                const SizedBox(height: 14),

                // Price + CTA row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'RM ${ride.totalPrice.toStringAsFixed(2)}',
                              style: AppTextStyles.price(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/tempat (fair rate + comm)',
                              style: AppTextStyles.caption(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    PillButton(
                      label: 'Tempah',
                      isSmall: true,
                      onPressed: onSecureSeat ?? onTap,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                PriceBreakdownRow(
                  fuelShare: ride.fuelShare,
                  tollShare: ride.tollShare,
                  platformFee: ride.platformFee,
                ),
              ],
            ),
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
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }
}
