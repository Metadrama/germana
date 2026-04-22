enum BookingRecordStatus {
  initiated,
  escrowHeld,
  pendingDriver,
  accepted,
  rejected,
  timedOut,
  inTrip,
  completed,
  refundPending,
  refunded,
}

class BookingRecord {
  final String id;
  final String rideId;
  final String passengerId;
  final BookingRecordStatus status;
  final double escrowAmount;
  final DateTime? holdAt;
  final DateTime? acceptedAt;
  final DateTime? timeoutAt;
  final DateTime? refundAt;

  const BookingRecord({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.status,
    required this.escrowAmount,
    this.holdAt,
    this.acceptedAt,
    this.timeoutAt,
    this.refundAt,
  });

  BookingRecord copyWith({
    String? id,
    String? rideId,
    String? passengerId,
    BookingRecordStatus? status,
    double? escrowAmount,
    DateTime? holdAt,
    DateTime? acceptedAt,
    DateTime? timeoutAt,
    DateTime? refundAt,
  }) {
    return BookingRecord(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      status: status ?? this.status,
      escrowAmount: escrowAmount ?? this.escrowAmount,
      holdAt: holdAt ?? this.holdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      timeoutAt: timeoutAt ?? this.timeoutAt,
      refundAt: refundAt ?? this.refundAt,
    );
  }
}
