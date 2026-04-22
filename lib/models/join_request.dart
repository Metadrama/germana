enum JoinRequestStatus {
  pending,
  accepted,
  rejected,
  expired,
  cancelled,
}

class JoinRequest {
  final String id;
  final String rideId;
  final String passengerId;
  final JoinRequestStatus status;
  final DateTime requestedAt;
  final DateTime? expiresAt;
  final DateTime? decisionAt;
  final String? reason;

  const JoinRequest({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.status,
    required this.requestedAt,
    this.expiresAt,
    this.decisionAt,
    this.reason,
  });

  JoinRequest copyWith({
    String? id,
    String? rideId,
    String? passengerId,
    JoinRequestStatus? status,
    DateTime? requestedAt,
    DateTime? expiresAt,
    DateTime? decisionAt,
    String? reason,
  }) {
    return JoinRequest(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      decisionAt: decisionAt ?? this.decisionAt,
      reason: reason ?? this.reason,
    );
  }
}
