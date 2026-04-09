/// Data model for a carpool ride listing.
class RideModel {
  final String id;
  final String origin;
  final String destination;
  final String driverAlias;
  final String? driverName;    // null until booked (escrow paid)
  final String? carPlate;      // null until booked
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
    required this.driverAlias,
    this.driverName,
    this.carPlate,
    required this.carModel,
    required this.departureTime,
    required this.totalSeats,
    required this.seatsLeft,
    required this.fuelShare,
    required this.tollShare,
    required this.platformFee,
    this.isBooked = false,
    this.rating,
  });

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
      driverAlias: driverAlias,
      driverName: name,
      carPlate: plate,
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
