import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/data/mock_my_rides.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/widgets/pill_button.dart';
import 'package:germana/widgets/section_label.dart';
import 'package:germana/widgets/status_badge.dart';
import 'package:intl/intl.dart';

/// My Rides tab — upcoming + past history.
class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final upcoming =
        mockMyRides.where((r) => r.departureTime.isAfter(DateTime.now())).toList();
    final past =
        mockMyRides.where((r) => r.departureTime.isBefore(DateTime.now())).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(l10n.myRidesTitle, style: AppTextStyles.display(context)),
          const SizedBox(height: 20),

          if (upcoming.isNotEmpty) ...[
            SectionLabel(label: l10n.upcoming),
            ...upcoming.map((ride) => _UpcomingRideCard(ride: ride)),
            const SizedBox(height: 24),
          ],

          if (past.isNotEmpty) ...[
            SectionLabel(label: l10n.past),
            ...past.map((ride) => _PastRideCard(ride: ride)),
          ],

          if (upcoming.isEmpty && past.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Icon(Icons.directions_car_outlined,
                        size: 64,
                        color: GermanaColors.of(context).textTertiary),
                    const SizedBox(height: 16),
                    Text(l10n.noRidesYet,
                        style: AppTextStyles.title(context)),
                    const SizedBox(height: 8),
                    Text(l10n.exploreRidesToStart,
                        style: AppTextStyles.bodySecondary(context)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UpcomingRideCard extends StatelessWidget {
  final RideModel ride;
  const _UpcomingRideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final l10n = AppLocalizations.of(context);
    final diff = ride.departureTime.difference(DateTime.now());
    final timeStr = diff.inMinutes < 60
        ? '${diff.inMinutes} min'
        : '${diff.inHours}j ${diff.inMinutes % 60}m';

    return GlassBox(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(ride.origin,
                          style: AppTextStyles.headline(context),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 16, color: colors.textTertiary),
                    ),
                    Flexible(
                      child: Text(ride.destination,
                          style: AppTextStyles.headline(context),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              StatusBadge.confirmed(),
            ],
          ),

          const SizedBox(height: 14),

          // Driver details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.glassSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentBlue.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      ride.driverName?.substring(0, 1) ?? '?',
                      style: AppTextStyles.headline(context)
                          .copyWith(color: AppColors.accentBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(ride.driverName ?? l10n.unknownDriver,
                          style: AppTextStyles.headline(context)
                              .copyWith(fontSize: 15)),
                      Row(
                        children: [
                          Text('${ride.carModel} · ',
                              style: AppTextStyles.caption(context)),
                          Text(ride.carPlate ?? '',
                              style: AppTextStyles.captionBold(context)
                                  .copyWith(letterSpacing: 0.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 14, color: colors.textTertiary),
              const SizedBox(width: 4),
              Text(
                l10n.arrivingIn(timeStr),
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              PillButton(
                label: l10n.arrived,
                color: AppColors.accentGreen,
                isSmall: true,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PastRideCard extends StatelessWidget {
  final RideModel ride;
  const _PastRideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);

    return GlassBox(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      opacity: 0.35,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(ride.origin,
                          style: AppTextStyles.headline(context)
                              .copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 14, color: colors.textTertiary),
                    ),
                    Flexible(
                      child: Text(ride.destination,
                          style: AppTextStyles.headline(context)
                              .copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormat('d MMM · h:mm a').format(ride.departureTime),
                      style: AppTextStyles.caption(context).copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    if (ride.driverName != null) ...[
                      Text(
                        ' · ',
                        style: AppTextStyles.caption(context).copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(ride.driverName!,
                          style: AppTextStyles.caption(context).copyWith(
                            color: colors.textSecondary,
                          )),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (ride.rating != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    size: 16, color: AppColors.accentAmber),
                const SizedBox(width: 2),
                Text(ride.rating!.toStringAsFixed(1),
                    style: AppTextStyles.captionBold(context)),
              ],
            ),
        ],
      ),
    );
  }
}
