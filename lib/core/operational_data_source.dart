import 'package:germana/data/mock_ledger.dart';
import 'package:germana/data/mock_my_rides.dart';
import 'package:germana/data/mock_rides_peninsular.dart';
import 'package:germana/models/ride_model.dart';

class OperationalDataSnapshot {
  final List<RideModel> marketplaceRides;
  final List<RideModel> passengerHistoryRides;
  final List<LedgerEntry> ledgerEntries;

  const OperationalDataSnapshot({
    required this.marketplaceRides,
    required this.passengerHistoryRides,
    required this.ledgerEntries,
  });
}

abstract class OperationalDataSource {
  String get label;

  OperationalDataSnapshot snapshot();
}

class MockOperationalDataSource implements OperationalDataSource {
  const MockOperationalDataSource();

  @override
  String get label => 'mock';

  @override
  OperationalDataSnapshot snapshot() {
    return OperationalDataSnapshot(
      marketplaceRides: List<RideModel>.from(mockRidesPeninsular),
      passengerHistoryRides: List<RideModel>.from(mockMyRides),
      ledgerEntries: List<LedgerEntry>.from(mockLedger),
    );
  }
}

OperationalDataSource resolveOperationalDataSource() {
  const mode = String.fromEnvironment(
    'OPERATIONAL_DATA_SOURCE',
    defaultValue: 'mock',
  );

  switch (mode.toLowerCase()) {
    case 'mock':
    default:
      return const MockOperationalDataSource();
  }
}