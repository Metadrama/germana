enum DriverRideStatus {
  draft,
  published,
  paused,
  requestPending,
  matched,
  boarding,
  inProgress,
  completed,
  cancelled,
}

class DriverRide {
  final String id;
  final String driverId;
  final String route; // Could be a more complex object in real app
  final String vehicle; // Could be a Vehicle model reference
  final double pricing;
  final int capacity;
  final DriverRideStatus status;
  final DateTime createdAt;
  final DateTime? publishedAt;

  const DriverRide({
    required this.id,
    required this.driverId,
    required this.route,
    required this.vehicle,
    required this.pricing,
    required this.capacity,
    required this.status,
    required this.createdAt,
    this.publishedAt,
  });

  DriverRide copyWith({
    String? id,
    String? driverId,
    String? route,
    String? vehicle,
    double? pricing,
    int? capacity,
    DriverRideStatus? status,
    DateTime? createdAt,
    DateTime? publishedAt,
  }) {
    return DriverRide(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      route: route ?? this.route,
      vehicle: vehicle ?? this.vehicle,
      pricing: pricing ?? this.pricing,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
