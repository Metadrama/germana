import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/widgets/pill_button.dart';
import 'package:germana/widgets/price_breakdown_row.dart';
import 'package:germana/widgets/status_badge.dart';
import 'package:germana/screens/explore/payment_screen.dart';
import 'package:germana/core/map_styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

/// Full ride detail screen — Hero transition, route viz, driver info, price, CTA.
class RideDetailScreen extends StatelessWidget {
  final RideModel ride;

  const RideDetailScreen({super.key, required this.ride});

  String _formatDeparture(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.inMinutes < 60) return 'Bertolak dalam ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Bertolak dalam ${diff.inHours}j ${diff.inMinutes % 60}m';
    return 'Bertolak ${DateFormat('EEE, h:mm a').format(dt)}';
  }

  String _sexLabel(AppLocalizations l10n) {
    return ride.driverSex == DriverSex.female ? l10n.sexFemale : l10n.sexMale;
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final l10n = AppLocalizations.of(context);

    // Default map location (Kuala Lumpur) since we don't have exact lat/lng in mock
    const initialCamera = CameraPosition(
      target: LatLng(3.140853, 101.693207),
      zoom: 13,
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // On web, avoid hard crashing when JS Maps SDK is not yet available.
          Positioned.fill(
            child: kIsWeb
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.background,
                          colors.background.withValues(alpha: 0.92),
                        ],
                      ),
                    ),
                  )
                : GoogleMap(
                    initialCameraPosition: initialCamera,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    style: Theme.of(context).brightness == Brightness.dark
                        ? AppMapStyles.darkMapStyle
                        : AppMapStyles.lightMapStyle,
                  ),
          ),
          
          SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.glassSurface,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const Spacer(),
                  Text(l10n.rideDetailsTitle, style: AppTextStyles.headline(context)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route visualizer
                    Hero(
                      tag: 'ride_${ride.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: GlassBox(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Origin
                              Row(
                                children: [
                                  Container(
                                    width: 12, height: 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(ride.origin,
                                        style: AppTextStyles.title(context)),
                                  ),
                                ],
                              ),
                              // Connecting line
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 2, height: 32,
                                      color: colors.textTertiary.withValues(alpha: 0.3),
                                    ),
                                  ],
                                ),
                              ),
                              // Destination
                              Row(
                                children: [
                                  Container(
                                    width: 12, height: 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.accentGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(ride.destination,
                                        style: AppTextStyles.title(context)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Driver info block
                    GlassBox(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentBlue.withValues(alpha: 0.1),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: AppColors.accentBlue, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ride.driverAlias,
                                    style: AppTextStyles.headline(context)
                                        .copyWith(fontSize: 15)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.verified_rounded,
                                        size: 14, color: AppColors.accentBlue),
                                    const SizedBox(width: 4),
                                    Text(l10n.verifiedIdentity,
                                        style: AppTextStyles.caption(context)
                                            .copyWith(color: AppColors.accentBlue)),
                                    const SizedBox(width: 8),
                                    Text('· ${_sexLabel(l10n)}',
                                        style: AppTextStyles.caption(context)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.lock_rounded,
                              size: 18, color: colors.textTertiary),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Details grid
                    GlassBox(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.pin_drop_outlined,
                            label: l10n.pickupLabel,
                            value: ride.pickupAddress,
                          ),
                          Divider(height: 20, color: colors.divider),
                          _DetailRow(
                            icon: Icons.straighten_rounded,
                            label: l10n.distanceLabel,
                            value: '${ride.distanceKm.toStringAsFixed(1)} km',
                          ),
                          Divider(height: 20, color: colors.divider),
                          _DetailRow(
                            icon: Icons.directions_car_rounded,
                            label: l10n.yourCar,
                            value: ride.carModel,
                          ),
                          Divider(height: 20, color: colors.divider),
                          _DetailRow(
                            icon: Icons.schedule_rounded,
                            label: l10n.departIn,
                            value: _formatDeparture(ride.departureTime),
                          ),
                          Divider(height: 20, color: colors.divider),
                          _DetailRow(
                            icon: Icons.event_seat_rounded,
                            label: l10n.seats,
                            value: '${ride.seatsLeft} dari ${ride.totalSeats}',
                            trailing: StatusBadge.seats(ride.seatsLeft),
                          ),
                        ],
                      ),
                    ),

                    if (ride.carPhotoUrl != null && ride.carPhotoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      GlassBox(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.carImage, style: AppTextStyles.caption(context)),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                ride.carPhotoUrl!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Price breakdown
                    GlassBox(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(l10n.pricePerSeat,
                              style: AppTextStyles.caption(context)),
                          const SizedBox(height: 4),
                          Text(
                            'RM ${ride.totalPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.price(context)
                                .copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 12),
                          PriceBreakdownRow(
                            fuelShare: ride.fuelShare,
                            tollShare: ride.tollShare,
                            platformFee: ride.platformFee,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: PillButton(
                        label: '${l10n.confirmPayment}  ·  RM ${ride.totalPrice.toStringAsFixed(2)}',
                        expand: true,
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 350),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 300),
                              pageBuilder: (_, __, ___) =>
                                  PaymentScreen(ride: ride),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        ], // Stack children
      ), // Stack
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.textTertiary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption(context)),
              const SizedBox(height: 2),
              Text(value,
                  style: AppTextStyles.body(context).copyWith(fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: trailing!,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
