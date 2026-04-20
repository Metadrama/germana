import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/widgets/pill_button.dart';
import 'package:germana/widgets/price_breakdown_row.dart';
import 'package:germana/widgets/route_timeline.dart';
import 'package:germana/widgets/driver_initials_avatar.dart';
import 'package:germana/widgets/ride_map_snippet.dart';
import 'package:germana/widgets/status_badge.dart';
import 'package:germana/screens/explore/payment_screen.dart';
import 'package:intl/intl.dart';

/// Full ride detail screen — Hero transition, route viz, driver info, price, CTA.
class RideDetailScreen extends StatefulWidget {
  final RideModel ride;

  const RideDetailScreen({super.key, required this.ride});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  static const int _warmRouteLimit = 12;
  static final LinkedHashSet<String> _warmRoutes = LinkedHashSet<String>();

  bool _showMap = false;

  String _routeKey() {
    String fmt(double? v) => v?.toStringAsFixed(5) ?? 'na';
    return '${fmt(widget.ride.pickupLat)},${fmt(widget.ride.pickupLng)}->${fmt(widget.ride.destinationLat)},${fmt(widget.ride.destinationLng)}';
  }

  void _touchWarmRoute(String key) {
    // LRU refresh behavior: remove then add to move route to newest position.
    _warmRoutes.remove(key);
    _warmRoutes.add(key);
    while (_warmRoutes.length > _warmRouteLimit) {
      _warmRoutes.remove(_warmRoutes.first);
    }
  }

  @override
  void initState() {
    super.initState();
    final key = _routeKey();
    final isWarm = _warmRoutes.contains(key);

    // For recently visited routes, mount map immediately.
    // For cold routes, keep a short delay so page transition remains smooth.
    final delay = isWarm
        ? Duration.zero
        : const Duration(milliseconds: 180);

    Future<void>.delayed(delay, () {
      if (!mounted) return;
      setState(() => _showMap = true);
      _touchWarmRoute(key);
    });
  }

  String _formatDeparture(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.inMinutes < 60) return 'Bertolak dalam ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Bertolak dalam ${diff.inHours}j ${diff.inMinutes % 60}m';
    return 'Bertolak ${DateFormat('EEE, h:mm a').format(dt)}';
  }

  String _sexLabel(AppLocalizations l10n) {
    return widget.ride.driverSex == DriverSex.female ? l10n.sexFemale : l10n.sexMale;
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final l10n = AppLocalizations.of(context);
    final appState = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
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
                    RouteTimelineCard(
                      originLabel: widget.ride.pickupAddress,
                      destinationLabel: widget.ride.destination,
                      departureTime: widget.ride.departureTime,
                      distanceKm: widget.ride.distanceKm,
                      subtitle: 'Journey path with departure and estimated arrival.',
                    ),

                    const SizedBox(height: 16),

                    _showMap
                        ? RideMapSnippet(
                            pickupLabel: widget.ride.pickupAddress,
                            destinationLabel: widget.ride.destination,
                            pickupLat: widget.ride.pickupLat,
                            pickupLng: widget.ride.pickupLng,
                            destinationLat: widget.ride.destinationLat,
                            destinationLng: widget.ride.destinationLng,
                            userLat: appState.currentLocationLat,
                            userLng: appState.currentLocationLng,
                          )
                        : GlassBox(
                            padding: EdgeInsets.zero,
                            child: SizedBox(
                              height: 210,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Preparing map…',
                                      style: AppTextStyles.caption(context),
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
                          DriverInitialsAvatar(
                            ride: widget.ride,
                            size: 48,
                            fontSize: 17,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.ride.driverDisplayName,
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
                            value: widget.ride.pickupAddress,
                          ),
                          Divider(height: 20, color: colors.divider),
                          _DetailRow(
                            icon: Icons.straighten_rounded,
                            label: l10n.distanceLabel,
                            value: '${widget.ride.distanceKm.toStringAsFixed(1)} km',
                          ),
                          Divider(height: 20, color: colors.divider),
                          _DetailRow(
                            icon: Icons.directions_car_rounded,
                            label: l10n.yourCar,
                            value: widget.ride.carModel,
                          ),
                          Divider(height: 20, color: colors.divider),
                          _DetailRow(
                            icon: Icons.schedule_rounded,
                            label: l10n.departIn,
                            value: _formatDeparture(widget.ride.departureTime),
                          ),
                          Divider(height: 20, color: colors.divider),
                          _DetailRow(
                            icon: Icons.event_seat_rounded,
                            label: l10n.seats,
                            value: '${widget.ride.seatsLeft}/${widget.ride.totalSeats} left',
                            trailing: StatusBadge.seats(
                              widget.ride.seatsLeft,
                              label: '${widget.ride.seatsLeft}/${widget.ride.totalSeats} left',
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (widget.ride.carPhotoUrl != null && widget.ride.carPhotoUrl!.isNotEmpty) ...[
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
                                widget.ride.carPhotoUrl!,
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
                            Text(l10n.fairRateLabel,
                              style: AppTextStyles.caption(context)),
                          const SizedBox(height: 4),
                          Text(
                            'RM ${widget.ride.totalPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.price(context)
                                .copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Individual now: RM ${widget.ride.currentIndividualRate.toStringAsFixed(2)} each (${widget.ride.activeRiders}/${widget.ride.totalSeats} onboard)',
                            style: AppTextStyles.caption(context).copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          PriceBreakdownRow(
                            fuelShare: widget.ride.fuelShare,
                            tollShare: widget.ride.tollShare,
                            platformFee: widget.ride.platformFee,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: PillButton(
                        label: '${l10n.confirmPayment}  ·  RM ${widget.ride.totalPrice.toStringAsFixed(2)}',
                        expand: true,
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 350),
                              reverseTransitionDuration:
                                  const Duration(milliseconds: 300),
                              pageBuilder: (_, __, ___) =>
                                  PaymentScreen(ride: widget.ride),
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
