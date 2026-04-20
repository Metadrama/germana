import 'package:flutter_test/flutter_test.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/models/ride_model.dart';

void main() {
  test('RideModel JSON roundtrip preserves key driver fields', () {
    final ride = RideModel(
      id: 'ride_1',
      origin: 'UniKL MIIT',
      destination: 'KL Sentral',
      destinationLat: 3.1340,
      destinationLng: 101.6869,
      pickupAddress: 'Gate A',
      pickupLat: 3.2078,
      pickupLng: 101.7282,
      distanceKm: 14.2,
      driverAlias: 'Verified Driver - UniKL MIIT',
      driverSex: DriverSex.female,
      driverName: 'Aina',
      carPlate: 'WXY 1234',
      carPhotoUrl: 'https://example.com/car.png',
      carModel: 'Perodua Myvi',
      departureTime: DateTime(2026, 4, 20, 10, 30),
      totalSeats: 4,
      seatsLeft: 2,
      fuelShare: 3.4,
      tollShare: 1.0,
      platformFee: 1.0,
      isBooked: true,
      rating: 4.8,
    );

    final encoded = ride.toJson();
    final decoded = RideModel.fromJson(encoded);

    expect(decoded.id, ride.id);
    expect(decoded.driverSex, DriverSex.female);
    expect(decoded.driverName, 'Aina');
    expect(decoded.carPlate, 'WXY 1234');
    expect(decoded.totalSeats, 4);
    expect(decoded.seatsLeft, 2);
    expect(decoded.isBooked, true);
    expect(decoded.departureTime.toIso8601String(), ride.departureTime.toIso8601String());
  });

  test('DriverManagedRide JSON roundtrip preserves requests and status', () {
    final ride = RideModel(
      id: 'ride_2',
      origin: 'Setapak',
      destination: 'KLCC',
      pickupAddress: 'Setapak Central',
      driverAlias: 'Verified Driver - UniKL',
      carModel: 'Honda City',
      departureTime: DateTime(2026, 4, 21, 9, 0),
      totalSeats: 4,
      seatsLeft: 3,
      fuelShare: 3.0,
      tollShare: 1.0,
      platformFee: 1.0,
    );

    final managed = DriverManagedRide(
      ride: ride,
      seatsLeft: 2,
      status: DriverListingStatus.published,
      requests: <RideJoinRequest>[
        RideJoinRequest(
          id: 'req_1',
          passengerName: 'Student A',
          requestedAt: DateTime(2026, 4, 20, 8, 0),
          expiresAt: DateTime(2026, 4, 20, 8, 15),
          status: RideRequestStatus.pending,
        ),
      ],
    );

    final encoded = managed.toJson();
    final decoded = DriverManagedRide.fromJson(encoded);

    expect(decoded.ride.id, 'ride_2');
    expect(decoded.status, DriverListingStatus.published);
    expect(decoded.seatsLeft, 2);
    expect(decoded.requests.length, 1);
    expect(decoded.requests.first.passengerName, 'Student A');
    expect(decoded.requests.first.status, RideRequestStatus.pending);
  });
}
