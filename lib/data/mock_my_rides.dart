import 'package:germana/models/ride_model.dart';

/// Booked/completed rides for "My Rides" tab.
/// 1 upcoming (driver revealed) + 3 past rides with ratings.
final List<RideModel> mockMyRides = [
  // Upcoming — driver identity revealed
  RideModel(
    id: 'myride_001',
    origin: 'UniKL MIIT, Gombak',
    destination: 'KL Sentral',
    driverAlias: 'Pemandu Disahkan · UniKL MIIT',
    driverName: 'Ahmad Faris',
    carPlate: 'WXY 1234',
    carModel: 'Perodua Myvi',
    departureTime: DateTime.now().add(const Duration(minutes: 12)),
    totalSeats: 4,
    seatsLeft: 2,
    fuelShare: 3.50,
    tollShare: 1.00,
    platformFee: 1.00,
    isBooked: true,
  ),

  // Past ride 1 — yesterday
  RideModel(
    id: 'myride_002',
    origin: 'Setapak',
    destination: 'Sunway Pyramid',
    driverAlias: 'Pemandu Disahkan',
    driverName: 'Nurul Aini',
    carPlate: 'BKJ 9087',
    carModel: 'Toyota Vios',
    departureTime: DateTime.now().subtract(const Duration(days: 1)),
    totalSeats: 4,
    seatsLeft: 0,
    fuelShare: 5.60,
    tollShare: 1.50,
    platformFee: 1.00,
    isBooked: true,
    rating: 4.8,
  ),

  // Past ride 2 — 3 days ago
  RideModel(
    id: 'myride_003',
    origin: 'Bukit Jalil',
    destination: 'KLCC',
    driverAlias: 'Pemandu Disahkan',
    driverName: 'Amir Haziq',
    carPlate: 'VDN 5566',
    carModel: 'Perodua Bezza',
    departureTime: DateTime.now().subtract(const Duration(days: 3)),
    totalSeats: 4,
    seatsLeft: 0,
    fuelShare: 2.80,
    tollShare: 1.00,
    platformFee: 1.00,
    isBooked: true,
    rating: 4.5,
  ),

  // Past ride 3 — last week
  RideModel(
    id: 'myride_004',
    origin: 'Shah Alam',
    destination: 'Sentul',
    driverAlias: 'Pemandu Disahkan',
    driverName: 'Izzat Hakim',
    carPlate: 'JMR 4421',
    carModel: 'Proton Saga',
    departureTime: DateTime.now().subtract(const Duration(days: 7)),
    totalSeats: 4,
    seatsLeft: 0,
    fuelShare: 4.10,
    tollShare: 1.80,
    platformFee: 1.00,
    isBooked: true,
    rating: 5.0,
  ),
];
