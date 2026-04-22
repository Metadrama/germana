enum PayoutRecordState {
  pending,
  processing,
  paid,
  failed,
}

class PayoutRecord {
  final String id;
  final String driverId;
  final double amount;
  final PayoutRecordState state;
  final DateTime initiatedAt;
  final DateTime? processedAt;
  final DateTime? failedAt;
  final String? failureReason;

  const PayoutRecord({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.state,
    required this.initiatedAt,
    this.processedAt,
    this.failedAt,
    this.failureReason,
  });

  PayoutRecord copyWith({
    String? id,
    String? driverId,
    double? amount,
    PayoutRecordState? state,
    DateTime? initiatedAt,
    DateTime? processedAt,
    DateTime? failedAt,
    String? failureReason,
  }) {
    return PayoutRecord(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      amount: amount ?? this.amount,
      state: state ?? this.state,
      initiatedAt: initiatedAt ?? this.initiatedAt,
      processedAt: processedAt ?? this.processedAt,
      failedAt: failedAt ?? this.failedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}
