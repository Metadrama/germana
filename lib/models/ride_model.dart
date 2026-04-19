/// Data model for a carpool ride listing.
enum DriverSex { male, female }

class RideModel {
  final String id;
  final String origin;
  final String destination;
  final double? destinationLat;
  final double? destinationLng;
  final String pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double distanceKm;
  final String driverAlias;
  final DriverSex driverSex;
  final String? driverName;    // null until booked (escrow paid)
  final String? carPlate;      // null until booked
  final String? carPhotoUrl;
  final String carModel;
  final DateTime departureTime;
  final int totalSeats;
  final int seatsLeft;
  final double fuelShare;
  final double tollShare;
  final double platformFee;
  final bool isBooked;
  final double? rating;        // for past rides

  const RideModel({
    required this.id,
    required this.origin,
    required this.destination,
    this.destinationLat,
    this.destinationLng,
    String? pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.distanceKm = 0,
    required this.driverAlias,
    this.driverSex = DriverSex.male,
    this.driverName,
    this.carPlate,
    this.carPhotoUrl,
    required this.carModel,
    required this.departureTime,
    required this.totalSeats,
    required this.seatsLeft,
    required this.fuelShare,
    required this.tollShare,
    required this.platformFee,
    this.isBooked = false,
    this.rating,
  }) : pickupAddress = pickupAddress ?? origin;

  double get totalPrice => fuelShare + tollShare + platformFee;

  /// Returns a copy with driver details revealed (post-booking).
  RideModel withDriverRevealed({
    required String name,
    required String plate,
  }) {
    return RideModel(
      id: id,
      origin: origin,
      destination: destination,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      pickupAddress: pickupAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      distanceKm: distanceKm,
      driverAlias: driverAlias,
      driverSex: driverSex,
      driverName: name,
      carPlate: plate,
      carPhotoUrl: carPhotoUrl,
      carModel: carModel,
      departureTime: departureTime,
      totalSeats: totalSeats,
      seatsLeft: seatsLeft - 1,
      fuelShare: fuelShare,
      tollShare: tollShare,
      platformFee: platformFee,
      isBooked: true,
    );
  }
}

/// Ledger transaction types.
enum TransactionType {
  escrowHold,
  platformFee,
  releasedToDriver,
  refund,
}

/// A single ledger entry.
class LedgerEntry {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String description;
  final String? rideRoute; // e.g. "MIIT → KL Sentral"

  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.rideRoute,
  });
}
