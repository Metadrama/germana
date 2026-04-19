import 'dart:math' as math;

import 'package:germana/models/ride_model.dart';
import 'package:germana/services/location_service.dart';

class NearbyRideResult {
  final RideModel ride;
  final double? distanceFromSearchKm;

  const NearbyRideResult({
    required this.ride,
    this.distanceFromSearchKm,
  });
}

class RideDiscoveryResult {
  final List<NearbyRideResult> rides;
  final double? appliedRadiusKm;

  const RideDiscoveryResult({
    required this.rides,
    this.appliedRadiusKm,
  });
}

class RideDiscoveryService {
  static const List<double> _radiusStepsKm = [8, 15, 25, 40];
  static const double _pickupRadiusKm = 35;

  static RideDiscoveryResult discover({
    required List<RideModel> rides,
    required String selectedFilter,
    required double currentLocationLat,
    required double currentLocationLng,
    PlaceDetails? selectedLocation,
  }) {
    final baseFiltered = _applyFeedFilter(rides, selectedFilter);
    final hasCurrentCoordinates =
        currentLocationLat != 0 || currentLocationLng != 0;

    final selectedLat = selectedLocation?.lat ?? 0;
    final selectedLng = selectedLocation?.lng ?? 0;
    final hasSelectedCoordinates = selectedLat != 0 || selectedLng != 0;
    final selectedName = (selectedLocation?.name ?? '').trim().toLowerCase();
    final hasSelectedText = selectedName.isNotEmpty;

    if (!hasSelectedCoordinates && !hasSelectedText) {
      final sorted = [...baseFiltered]..sort(_sortBySoonestThenPrice);
      return RideDiscoveryResult(
        rides: sorted.map((ride) => NearbyRideResult(ride: ride)).toList(),
      );
    }

    final candidates = <_RideCandidate>[];
    for (final ride in baseFiltered) {
      double? pickupDistance;
      if (hasCurrentCoordinates && ride.pickupLat != null && ride.pickupLng != null) {
        pickupDistance = _haversineKm(
          currentLocationLat,
          currentLocationLng,
          ride.pickupLat!,
          ride.pickupLng!,
        );
        if (pickupDistance > _pickupRadiusKm) continue;
      }

      double? destinationDistance;
      if (hasSelectedCoordinates &&
          ride.destinationLat != null &&
          ride.destinationLng != null) {
        destinationDistance = _haversineKm(
          selectedLat,
          selectedLng,
          ride.destinationLat!,
          ride.destinationLng!,
        );
      }

      final destinationTextMatch = hasSelectedText &&
          _matchesDestinationText(
            selectedName,
            ride.destination,
            ride.origin,
            ride.pickupAddress,
          );

      candidates.add(
        _RideCandidate(
          ride: ride,
          pickupDistanceKm: pickupDistance,
          destinationDistanceKm: destinationDistance,
          destinationTextMatch: destinationTextMatch,
        ),
      );
    }

    if (candidates.isEmpty) {
      return const RideDiscoveryResult(rides: []);
    }

    double chosenRadius = _radiusStepsKm.last;
    List<_RideCandidate> within = [];

    for (final radius in _radiusStepsKm) {
      final scoped = candidates
          .where((item) {
            final byDistance = item.destinationDistanceKm != null &&
                item.destinationDistanceKm! <= radius;
            return byDistance || item.destinationTextMatch;
          })
          .toList();
      if (scoped.length >= 3) {
        chosenRadius = radius;
        within = scoped;
        break;
      }
      within = scoped;
      chosenRadius = radius;
    }

    if (within.isEmpty) {
      return RideDiscoveryResult(rides: const [], appliedRadiusKm: chosenRadius);
    }

    within.sort((a, b) {
      final aScore = _rankingScore(
        ride: a.ride,
        pickupDistanceKm: a.pickupDistanceKm,
        destinationDistanceKm: a.destinationDistanceKm,
        destinationTextMatch: a.destinationTextMatch,
      );
      final bScore = _rankingScore(
        ride: b.ride,
        pickupDistanceKm: b.pickupDistanceKm,
        destinationDistanceKm: b.destinationDistanceKm,
        destinationTextMatch: b.destinationTextMatch,
      );
      return aScore.compareTo(bScore);
    });

    return RideDiscoveryResult(
      rides: within
          .map(
            (item) => NearbyRideResult(
              ride: item.ride,
              distanceFromSearchKm: item.destinationDistanceKm,
            ),
          )
          .toList(),
      appliedRadiusKm: chosenRadius,
    );
  }

  static List<RideModel> _applyFeedFilter(List<RideModel> rides, String filter) {
    final now = DateTime.now();

    switch (filter) {
      case 'now':
        return rides
            .where((ride) =>
                ride.departureTime.isAfter(now) &&
                ride.departureTime.difference(now).inMinutes <= 90)
            .toList();
      case 'scheduled':
        return rides
            .where((ride) => ride.departureTime.difference(now).inHours >= 2)
            .toList();
      case 'under5':
        return rides.where((ride) => ride.totalPrice < 5).toList();
      case 'seats3':
        return rides.where((ride) => ride.seatsLeft >= 3).toList();
      case 'all':
      default:
        return [...rides];
    }
  }

  static int _sortBySoonestThenPrice(RideModel a, RideModel b) {
    final byTime = a.departureTime.compareTo(b.departureTime);
    if (byTime != 0) return byTime;
    return a.totalPrice.compareTo(b.totalPrice);
  }

  static bool _matchesDestinationText(
    String selectedName,
    String destination,
    String origin,
    String pickupAddress,
  ) {
    if (selectedName.isEmpty) return false;

    final destinationText = destination.toLowerCase();
    final originText = origin.toLowerCase();
    final pickupText = pickupAddress.toLowerCase();

    return destinationText.contains(selectedName) ||
        selectedName.contains(destinationText) ||
        pickupText.contains(selectedName) ||
        originText.contains(selectedName);
  }

  static double _rankingScore({
    required RideModel ride,
    required double? pickupDistanceKm,
    required double? destinationDistanceKm,
    required bool destinationTextMatch,
  }) {
    final now = DateTime.now();
    final minutesAway = ride.departureTime.difference(now).inMinutes.clamp(0, 24 * 60);
    final timePenalty = minutesAway / 60.0;
    final pricePenalty = ride.totalPrice / 10.0;

    final pickupPenalty = (pickupDistanceKm ?? 18) / 18.0;
    final destinationPenalty = destinationTextMatch
        ? 0.0
        : ((destinationDistanceKm ?? 40) / 20.0);

    return (destinationPenalty * 0.50) +
        (pickupPenalty * 0.20) +
        (timePenalty * 0.20) +
        (pricePenalty * 0.10);
  }

  static double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180);
}

class _RideCandidate {
  final RideModel ride;
  final double? pickupDistanceKm;
  final double? destinationDistanceKm;
  final bool destinationTextMatch;

  const _RideCandidate({
    required this.ride,
    required this.pickupDistanceKm,
    required this.destinationDistanceKm,
    required this.destinationTextMatch,
  });
}
