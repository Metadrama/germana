import 'dart:async';

import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/widgets/section_label.dart';

class DriverHubScreen extends StatefulWidget {
  const DriverHubScreen({super.key});

  @override
  State<DriverHubScreen> createState() => _DriverHubScreenState();
}

class _DriverHubScreenState extends State<DriverHubScreen> {
  bool _sweptOnce = false;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      AppStateProvider.of(context).expirePendingJoinRequests();
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sweptOnce) return;
    _sweptOnce = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppStateProvider.of(context).expirePendingJoinRequests();
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final rides = state.driverManagedRides;

    final activeListings = rides
        .where((r) =>
            r.status == DriverListingStatus.published ||
        r.status == DriverListingStatus.paused)
        .length;

    final pendingRequests = rides
        .expand((r) => r.requests)
        .where((req) => req.status == RideRequestStatus.pending)
        .length;

    final tripsInProgress = rides
        .where((r) => r.status == DriverListingStatus.inProgress)
        .length;

    final completedTrips = rides
        .where((r) => r.status == DriverListingStatus.completed)
        .length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text('Driver Hub', style: AppTextStyles.display(context)),
          const SizedBox(height: 8),
          Text(
            'Manage your listings, pending approvals, and trip operations in one place.',
            style: AppTextStyles.bodySecondary(context),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              _KpiCard(
                title: 'Active Listings',
                value: '$activeListings',
                accent: AppColors.accentBlue,
              ),
              _KpiCard(
                title: 'Pending Requests',
                value: '$pendingRequests',
                accent: AppColors.accentAmber,
              ),
              _KpiCard(
                title: 'Trips In Progress',
                value: '$tripsInProgress',
                accent: AppColors.accentGreen,
              ),
              _KpiCard(
                title: 'Completed',
                value: '$completedTrips',
                accent: AppColors.accentSky,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionLabel(label: 'Recent Listings', trailing: '${rides.length} total'),
          if (rides.isEmpty)
            GlassBox(
              padding: const EdgeInsets.all(14),
              child: Text(
                'No listings yet. Create one from the List tab to start receiving requests.',
                style: AppTextStyles.caption(context),
              ),
            ),
          ...rides.take(6).map((managed) {
            final ride = managed.resolvedRide;
            final requests = List<RideJoinRequest>.from(managed.requests)
              ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
            final pending = managed.requests
                .where((req) => req.status == RideRequestStatus.pending)
                .length;
            return GlassBox(
              margin: const EdgeInsets.only(bottom: 10),
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
                      _StatusChip(status: managed.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${ride.seatsLeft}/${ride.totalSeats} seats left · $pending pending',
                    style: AppTextStyles.caption(context),
                  ),
                  const SizedBox(height: 10),
                  if (requests.isEmpty)
                    Text(
                      'No passenger requests yet.',
                      style: AppTextStyles.caption(context).copyWith(
                        color: GermanaColors.of(context).textSecondary,
                      ),
                    )
                  else
                    ...requests.take(3).map(
                      (request) => _RequestRow(request: request),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption(context).copyWith(color: GermanaColors.of(context).textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.display(context).copyWith(
              fontSize: 30,
              color: accent,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DriverListingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color tint;

    switch (status) {
      case DriverListingStatus.draft:
        label = 'Draft';
        tint = AppColors.feeNeutral;
      case DriverListingStatus.published:
        label = 'Open';
        tint = AppColors.accentGreen;
      case DriverListingStatus.paused:
        label = 'Paused';
        tint = AppColors.accentAmber;
      case DriverListingStatus.inProgress:
        label = 'In Progress';
        tint = AppColors.accentBlue;
      case DriverListingStatus.completed:
        label = 'Completed';
        tint = AppColors.accentSky;
      case DriverListingStatus.cancelled:
        label = 'Cancelled';
        tint = AppColors.accentRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

class _RequestRow extends StatelessWidget {
  final RideJoinRequest request;

  const _RequestRow({required this.request});

  String _timeMeta() {
    final now = DateTime.now();
    if (request.status == RideRequestStatus.pending) {
      final remaining = request.expiresAt.difference(now).inMinutes;
      if (remaining <= 0) return 'Expiring now';
      return '$remaining min left';
    }
    if (request.decidedAt != null) {
      final ago = now.difference(request.decidedAt!).inMinutes;
      if (ago < 1) return 'Just now';
      return '$ago min ago';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final reason = request.decisionReason?.trim();
    final hasReason = reason != null && reason.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colors.glassSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.glassBorderSubtle, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.passengerName,
                    style: AppTextStyles.captionBold(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _RequestStatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _timeMeta(),
              style: AppTextStyles.caption(context).copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (hasReason) ...[
              const SizedBox(height: 3),
              Text(
                reason,
                style: AppTextStyles.caption(context).copyWith(
                  color: colors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequestStatusChip extends StatelessWidget {
  final RideRequestStatus status;

  const _RequestStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
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
