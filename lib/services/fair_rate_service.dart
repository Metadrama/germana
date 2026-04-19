class FairRateInput {
  final double distanceKm;
  final double fuelConsumptionLPer100Km;
  final double fuelPricePerLiter;
  final int seats;
  final double tollRm;

  const FairRateInput({
    required this.distanceKm,
    required this.fuelConsumptionLPer100Km,
    required this.fuelPricePerLiter,
    required this.seats,
    required this.tollRm,
  });
}

class FairRateBreakdown {
  final double fuelRm;
  final double tollRm;
  final double maintenanceRm;
  final double incidentalsRm;
  final double driverSafetyMarginRm;
  final double subtotalRm;
  final double perSeatRecommendedRm;
  final double perSeatLowerRm;
  final double perSeatUpperRm;

  const FairRateBreakdown({
    required this.fuelRm,
    required this.tollRm,
    required this.maintenanceRm,
    required this.incidentalsRm,
    required this.driverSafetyMarginRm,
    required this.subtotalRm,
    required this.perSeatRecommendedRm,
    required this.perSeatLowerRm,
    required this.perSeatUpperRm,
  });
}

class FairRateService {
  static const double _maintenanceRmPerKm = 0.12;
  static const double _driverSafetyMarginPct = 0.06;

  FairRateBreakdown calculate(FairRateInput input) {
    final seats = input.seats.clamp(1, 6);
    final fuelLiters = (input.distanceKm / 100) * input.fuelConsumptionLPer100Km;
    final fuelRm = fuelLiters * input.fuelPricePerLiter;

    final maintenanceRm = input.distanceKm * _maintenanceRmPerKm;
    final incidentalsRm = _incidentals(input.distanceKm);
    final subtotalRm = fuelRm + input.tollRm + maintenanceRm + incidentalsRm;
    final safetyRm = subtotalRm * _driverSafetyMarginPct;

    final recommended = (subtotalRm + safetyRm) / seats;
    final lower = recommended * 0.95;
    final upper = recommended * 1.12;

    return FairRateBreakdown(
      fuelRm: _round2(fuelRm),
      tollRm: _round2(input.tollRm),
      maintenanceRm: _round2(maintenanceRm),
      incidentalsRm: _round2(incidentalsRm),
      driverSafetyMarginRm: _round2(safetyRm),
      subtotalRm: _round2(subtotalRm + safetyRm),
      perSeatRecommendedRm: _round2(recommended),
      perSeatLowerRm: _round2(lower),
      perSeatUpperRm: _round2(upper),
    );
  }

  double _incidentals(double distanceKm) {
    final dynamic = (distanceKm * 0.02).clamp(0.5, 4.0);
    return dynamic.toDouble();
  }

  double _round2(double value) => double.parse(value.toStringAsFixed(2));
}
