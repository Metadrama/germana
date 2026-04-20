import 'package:flutter_test/flutter_test.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/models/ride_model.dart';

RideModel _sampleRide({required String id}) {
  return RideModel(
    id: id,
    origin: 'UniKL MIIT',
    destination: 'KL Sentral',
    pickupAddress: 'Gate A',
    distanceKm: 14.2,
    driverAlias: 'Verified Driver - UniKL MIIT',
    driverSex: DriverSex.male,
    carModel: 'Perodua Myvi',
    departureTime: DateTime(2026, 4, 21, 9, 0),
    totalSeats: 4,
    seatsLeft: 4,
    fuelShare: 3.5,
    tollShare: 1.0,
    platformFee: 1.0,
  );
}

void main() {
  test('invalid status transition published -> completed is blocked', () {
    final state = AppState();
    state.publishDriverRide(_sampleRide(id: 'ride_status_blocked'));

    state.setDriverRideStatus(
      rideId: 'ride_status_blocked',
      status: DriverListingStatus.completed,
    );

    expect(state.driverManagedRides.first.status, DriverListingStatus.published);
  });

  test('inProgress requires at least one accepted request', () {
    final state = AppState();
    state.publishDriverRide(_sampleRide(id: 'ride_in_progress_rule'));

    state.setDriverRideStatus(
      rideId: 'ride_in_progress_rule',
      status: DriverListingStatus.inProgress,
    );
    expect(state.driverManagedRides.first.status, DriverListingStatus.published);

    final requestId = state.addJoinRequest(
      rideId: 'ride_in_progress_rule',
      passengerName: 'Student A',
    );
    state.acceptJoinRequest(
      rideId: 'ride_in_progress_rule',
      requestId: requestId,
    );

    state.setDriverRideStatus(
      rideId: 'ride_in_progress_rule',
      status: DriverListingStatus.inProgress,
    );

    expect(state.driverManagedRides.first.status, DriverListingStatus.inProgress);
  });

  test('pending requests auto-expire after TTL sweep', () {
    final state = AppState();
    state.publishDriverRide(_sampleRide(id: 'ride_expiry'));

    final requestId = state.addJoinRequest(
      rideId: 'ride_expiry',
      passengerName: 'Student B',
    );

    final requestedAt = state.driverManagedRides.first.requests.first.requestedAt;
    state.expirePendingJoinRequests(
      now: requestedAt.add(const Duration(minutes: 16)),
    );

    final request = state.driverManagedRides.first.requests
        .firstWhere((r) => r.id == requestId);
    expect(request.status, RideRequestStatus.expired);
    expect(request.decisionReason, isNotNull);
    expect(request.decidedAt, isNotNull);
  });
}
