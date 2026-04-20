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

  RideModel copyWith({
    String? id,
    String? origin,
    String? destination,
    double? destinationLat,
    double? destinationLng,
    String? pickupAddress,
    double? pickupLat,
    double? pickupLng,
    double? distanceKm,
    String? driverAlias,
    DriverSex? driverSex,
    String? driverName,
    String? carPlate,
    String? carPhotoUrl,
    String? carModel,
    DateTime? departureTime,
    int? totalSeats,
    int? seatsLeft,
    double? fuelShare,
    double? tollShare,
    double? platformFee,
    bool? isBooked,
    double? rating,
  }) {
    return RideModel(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      distanceKm: distanceKm ?? this.distanceKm,
      driverAlias: driverAlias ?? this.driverAlias,
      driverSex: driverSex ?? this.driverSex,
      driverName: driverName ?? this.driverName,
      carPlate: carPlate ?? this.carPlate,
      carPhotoUrl: carPhotoUrl ?? this.carPhotoUrl,
      carModel: carModel ?? this.carModel,
      departureTime: departureTime ?? this.departureTime,
      totalSeats: totalSeats ?? this.totalSeats,
      seatsLeft: seatsLeft ?? this.seatsLeft,
      fuelShare: fuelShare ?? this.fuelShare,
      tollShare: tollShare ?? this.tollShare,
      platformFee: platformFee ?? this.platformFee,
      isBooked: isBooked ?? this.isBooked,
      rating: rating ?? this.rating,
    );
  }

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      destinationLat: (json['destinationLat'] as num?)?.toDouble(),
      destinationLng: (json['destinationLng'] as num?)?.toDouble(),
      pickupAddress: json['pickupAddress'] as String?,
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      driverAlias: json['driverAlias'] as String? ?? '',
      driverSex: _driverSexFromString(json['driverSex'] as String?),
      driverName: json['driverName'] as String?,
      carPlate: json['carPlate'] as String?,
      carPhotoUrl: json['carPhotoUrl'] as String?,
      carModel: json['carModel'] as String? ?? '',
      departureTime: DateTime.tryParse(json['departureTime'] as String? ?? '') ?? DateTime.now(),
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 0,
      seatsLeft: (json['seatsLeft'] as num?)?.toInt() ?? 0,
      fuelShare: (json['fuelShare'] as num?)?.toDouble() ?? 0,
      tollShare: (json['tollShare'] as num?)?.toDouble() ?? 0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0,
      isBooked: json['isBooked'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'origin': origin,
      'destination': destination,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'distanceKm': distanceKm,
      'driverAlias': driverAlias,
      'driverSex': driverSex.name,
      'driverName': driverName,
      'carPlate': carPlate,
      'carPhotoUrl': carPhotoUrl,
      'carModel': carModel,
      'departureTime': departureTime.toIso8601String(),
      'totalSeats': totalSeats,
      'seatsLeft': seatsLeft,
      'fuelShare': fuelShare,
      'tollShare': tollShare,
      'platformFee': platformFee,
      'isBooked': isBooked,
      'rating': rating,
    };
  }

  static DriverSex _driverSexFromString(String? raw) {
    return raw == DriverSex.female.name ? DriverSex.female : DriverSex.male;
  }

  double get totalPrice => fuelShare + tollShare + platformFee;

  bool get hasExplicitDriverName =>
      driverName != null && driverName!.trim().isNotEmpty;

  static const List<String> _fallbackFirstNames = <String>[
    'Adam',
    'Aiman',
    'Amir',
    'Faris',
    'Hakim',
    'Irfan',
    'Rayyan',
    'Zaid',
    'Alya',
    'Aina',
    'Hana',
    'Izzah',
  ];

  static const List<String> _fallbackLastNames = <String>[
    'Iskandar',
    'Haziq',
    'Syafiq',
    'Nadim',
    'Farhan',
    'Aqil',
    'Amni',
    'Danish',
    'Sofea',
    'Nadia',
    'Aisyah',
    'Imani',
  ];

  int _stableSeed() {
    var seed = 17;
    final source = '$id|$driverAlias';
    for (final unit in source.codeUnits) {
      seed = (seed * 31 + unit) & 0x7fffffff;
    }
    return seed;
  }

  String _generatedDriverName() {
    final seed = _stableSeed();
    final first = _fallbackFirstNames[seed % _fallbackFirstNames.length];
    final last = _fallbackLastNames[(seed ~/ _fallbackFirstNames.length) % _fallbackLastNames.length];
    return '$first $last';
  }

  bool _looksLikeOrganizationOrPlace(String value) {
    final lower = value.toLowerCase();
    const orgKeywords = <String>[
      'unikl',
      'uitm',
      'ukm',
      'utm',
      'usm',
      'uum',
      'unimap',
      'utp',
      'iium',
      'upm',
      'ump',
      'university',
      'kampus',
      'campus',
      'station',
      'terminal',
      'sentral',
      'klia',
      'gate',
    ];
    return orgKeywords.any(lower.contains);
  }

  String get driverDisplayName {
    final raw = hasExplicitDriverName
        ? driverName!.trim()
        : driverAlias
            .replaceFirst(RegExp(r'^Verified Driver\s*[-·:]\s*', caseSensitive: false), '')
            .replaceFirst(RegExp(r'^Pemandu\s+Disahkan\s*[-·:]\s*', caseSensitive: false), '')
            .trim();

    if (raw.isEmpty) return _generatedDriverName();

    if (!hasExplicitDriverName && _looksLikeOrganizationOrPlace(raw)) {
      return _generatedDriverName();
    }

    final parts = raw.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return _generatedDriverName();

    final capped = parts.length > 2 ? parts.sublist(0, 2) : parts;
    return capped
        .map((p) => p.length == 1
            ? p.toUpperCase()
            : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
  }

  String get driverInitials {
    final parts = driverDisplayName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'D';
    if (parts.length == 1) {
      final first = parts.first;
      return first.isEmpty ? 'D' : first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  int get activeRiders {
    final occupied = totalSeats - seatsLeft;
    return occupied < 1 ? 1 : occupied;
  }

  double get currentIndividualRate => totalPrice / activeRiders;

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

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'] as String? ?? '',
      type: _transactionTypeFromString(json['type'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      description: json['description'] as String? ?? '',
      rideRoute: json['rideRoute'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'rideRoute': rideRoute,
    };
  }

  static TransactionType _transactionTypeFromString(String? raw) {
    switch (raw) {
      case 'escrowHold':
        return TransactionType.escrowHold;
      case 'platformFee':
        return TransactionType.platformFee;
      case 'releasedToDriver':
        return TransactionType.releasedToDriver;
      case 'refund':
        return TransactionType.refund;
      default:
        return TransactionType.escrowHold;
    }
  }
}
