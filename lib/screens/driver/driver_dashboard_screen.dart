import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/widgets/section_label.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  String _statusLabel(DriverListingStatus status) {
    switch (status) {
      case DriverListingStatus.draft:
        return 'Draft';
      case DriverListingStatus.published:
        return 'Open';
      case DriverListingStatus.paused:
        return 'Paused';
      case DriverListingStatus.inProgress:
        return 'Trip Started';
      case DriverListingStatus.completed:
        return 'Completed';
      case DriverListingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _statusColor(DriverListingStatus status) {
    switch (status) {
      case DriverListingStatus.published:
        return AppColors.accentGreen;
      case DriverListingStatus.paused:
        return AppColors.accentAmber;
      case DriverListingStatus.inProgress:
        return AppColors.accentBlue;
      case DriverListingStatus.completed:
        return AppColors.accentSky;
      case DriverListingStatus.cancelled:
        return AppColors.accentRed;
      case DriverListingStatus.draft:
        return AppColors.feeNeutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final colors = GermanaColors.of(context);
    final l10n = AppLocalizations.of(context);
    final rides = state.driverManagedRides;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        children: [
          Text(
            'Manage your active carpool listings and requests.',
            style: AppTextStyles.caption(context).copyWith(color: colors.textSecondary),
          ),
          if (state.hasSeededDriverScenario) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.accentAmber.withValues(alpha: 0.45),
                    width: 0.9,
                  ),
                ),
                child: Text(
                  'Testing mode active',
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.accentAmber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          GlassBox(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Mock testing scenario',
                    style: AppTextStyles.captionBold(context),
                  ),
                ),
                TextButton(
                  onPressed: state.hasSeededDriverScenario
                      ? null
                      : () {
                          state.seedDriverTestingScenario();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mock driver scenario loaded.')),
                          );
                        },
                  child: const Text('Load'),
                ),
                TextButton(
                  onPressed: state.hasSeededDriverScenario
                      ? () {
                          state.clearSeededDriverScenario();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mock driver scenario cleared.')),
                          );
                        }
                      : null,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionLabel(label: 'Active Listings', trailing: '${rides.length}'),
          if (rides.isEmpty)
            GlassBox(
              padding: const EdgeInsets.all(14),
              child: Text(
                'No active listings yet. Create one via ${l10n.listRide}.',
                style: AppTextStyles.caption(context),
              ),
            ),
          ...rides.map((managed) {
            final ride = managed.resolvedRide;
            final pending = managed.requests.where((r) => r.status == RideRequestStatus.pending).length;
            return GlassBox(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${ride.origin} -> ${ride.destination}',
                          style: AppTextStyles.headline(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(managed.status).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _statusLabel(managed.status),
                          style: AppTextStyles.caption(context).copyWith(
                            color: _statusColor(managed.status),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${ride.departureTime.toLocal()} · ${ride.seatsLeft}/${ride.totalSeats} seats left',
                    style: AppTextStyles.caption(context),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _actionChip(
                        context,
                        label: managed.status == DriverListingStatus.paused ? 'Resume' : 'Pause',
                        onTap: () {
                          state.setDriverRideStatus(
                            rideId: ride.id,
                            status: managed.status == DriverListingStatus.paused
                                ? DriverListingStatus.published
                                : DriverListingStatus.paused,
                          );
                        },
                      ),
                      _actionChip(
                        context,
                        label: 'Start trip',
                        onTap: () {
                          state.setDriverRideStatus(
                            rideId: ride.id,
                            status: DriverListingStatus.inProgress,
                          );
                        },
                      ),
                      _actionChip(
                        context,
                        label: 'Complete',
                        onTap: () {
                          state.setDriverRideStatus(
                            rideId: ride.id,
                            status: DriverListingStatus.completed,
                          );
                        },
                      ),
                      _actionChip(
                        context,
                        label: 'Mock incoming request',
                        onTap: () {
                          final requestId = state.addJoinRequest(
                            rideId: ride.id,
                            passengerName: 'Student ${DateTime.now().second.toString().padLeft(2, '0')}',
                          );
                          if (requestId.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('New request added.')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pending requests: $pending',
                    style: AppTextStyles.captionBold(context),
                  ),
                  const SizedBox(height: 8),
                  if (managed.requests.isEmpty)
                    Text(
                      'No requests yet.',
                      style: AppTextStyles.caption(context),
                    ),
                  ...managed.requests.take(4).map((req) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              req.passengerName,
                              style: AppTextStyles.caption(context),
                            ),
                          ),
                          _requestStatusChip(context, req.status),
                          if (req.status == RideRequestStatus.pending) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                state.acceptJoinRequest(
                                  rideId: ride.id,
                                  requestId: req.id,
                                  reason: 'Approved by driver for this student carpool trip.',
                                );
                              },
                              icon: const Icon(Icons.check_rounded, color: AppColors.accentGreen),
                              tooltip: 'Accept',
                            ),
                            IconButton(
                              onPressed: () {
                                state.rejectJoinRequest(
                                  rideId: ride.id,
                                  requestId: req.id,
                                  reason: 'Not approved due to seat planning or route fit.',
                                );
                              },
                              icon: const Icon(Icons.close_rounded, color: AppColors.accentRed),
                              tooltip: 'Reject',
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _actionChip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = GermanaColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.glassBorderSubtle),
        ),
        child: Text(label, style: AppTextStyles.caption(context)),
      ),
    );
  }

  Widget _requestStatusChip(BuildContext context, RideRequestStatus status) {
    final colors = GermanaColors.of(context);
    late final String label;
    late final Color tint;
    switch (status) {
      case RideRequestStatus.pending:
        label = 'Pending';
        tint = AppColors.accentAmber;
      case RideRequestStatus.accepted:
        label = 'Accepted';
        tint = AppColors.accentGreen;
      case RideRequestStatus.rejected:
        label = 'Rejected';
        tint = AppColors.accentRed;
      case RideRequestStatus.expired:
        label = 'Expired';
        tint = AppColors.feeNeutral;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(context).copyWith(
          color: tint,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
