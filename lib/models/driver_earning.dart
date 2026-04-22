enum EarningRecordState {
  pending,
  available,
  processed,
}

class DriverEarningRecord {
  final String id;
  final String rideId;
  final double gross;
  final double platformFee;
  final double net;
  final EarningRecordState state;
  final DateTime createdAt;
  final String? payoutBatchId;

  const DriverEarningRecord({
    required this.id,
    required this.rideId,
    required this.gross,
    required this.platformFee,
    required this.net,
    required this.state,
    required this.createdAt,
    this.payoutBatchId,
  });

  DriverEarningRecord copyWith({
    String? id,
    String? rideId,
    double? gross,
    double? platformFee,
    double? net,
    EarningRecordState? state,
    DateTime? createdAt,
    String? payoutBatchId,
  }) {
    return DriverEarningRecord(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      gross: gross ?? this.gross,
      platformFee: platformFee ?? this.platformFee,
      net: net ?? this.net,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      payoutBatchId: payoutBatchId ?? this.payoutBatchId,
    );
  }
}
