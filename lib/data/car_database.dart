/// Germana Malaysian Vehicle Database
/// Covers 14 brands, 80+ models sold in Malaysia from 2016–2025.
/// Fuel consumption figures are real-world averages (L/100km).
/// Seat counts are passenger seats (excluding driver).

enum BodyType {
  sedan,
  hatchback,
  suv,
  mpv,
  pickup,
}

class CarModel {
  final String brand;
  final String model;
  final BodyType bodyType;
  final double fuelConsumption; // L/100km real-world avg
  final int passengerSeats;    // excluding driver
  final int yearFrom;          // first year sold in MY
  final int? yearTo;           // null = still on sale
  final String? engineCC;      // e.g. "1.5L"

  const CarModel({
    required this.brand,
    required this.model,
    required this.bodyType,
    required this.fuelConsumption,
    required this.passengerSeats,
    required this.yearFrom,
    this.yearTo,
    this.engineCC,
  });

  String get displayName => '$brand $model';
  String get fuelLabel => '${fuelConsumption.toStringAsFixed(1)} L/100km';
  String get seatLabel => '$passengerSeats tempat';
  bool get isCurrentlyOnSale => yearTo == null;
}

/// All brands available in Malaysia, sorted by market share.
const List<String> malaysiaBrands = [
  'Perodua',
  'Proton',
  'Honda',
  'Toyota',
  'Nissan',
  'Mazda',
  'Hyundai',
  'Kia',
  'Mitsubishi',
  'Suzuki',
  'Subaru',
  'Volkswagen',
  'BMW',
  'Mercedes-Benz',
];

/// Complete Malaysian car database.
const List<CarModel> malaysiaCarDatabase = [
  // ──────────── PERODUA ────────────
  CarModel(brand: 'Perodua', model: 'Axia', bodyType: BodyType.hatchback, fuelConsumption: 4.1, passengerSeats: 4, yearFrom: 2014, engineCC: '1.0L'),
  CarModel(brand: 'Perodua', model: 'Myvi', bodyType: BodyType.hatchback, fuelConsumption: 5.1, passengerSeats: 4, yearFrom: 2005, engineCC: '1.5L'),
  CarModel(brand: 'Perodua', model: 'Bezza', bodyType: BodyType.sedan, fuelConsumption: 4.6, passengerSeats: 4, yearFrom: 2016, engineCC: '1.3L'),
  CarModel(brand: 'Perodua', model: 'Alza', bodyType: BodyType.mpv, fuelConsumption: 6.0, passengerSeats: 6, yearFrom: 2009, engineCC: '1.5L'),
  CarModel(brand: 'Perodua', model: 'Ativa', bodyType: BodyType.suv, fuelConsumption: 5.3, passengerSeats: 4, yearFrom: 2021, engineCC: '1.0T'),
  CarModel(brand: 'Perodua', model: 'Aruz', bodyType: BodyType.suv, fuelConsumption: 6.6, passengerSeats: 6, yearFrom: 2019, engineCC: '1.5L'),
  CarModel(brand: 'Perodua', model: 'Viva', bodyType: BodyType.hatchback, fuelConsumption: 4.5, passengerSeats: 4, yearFrom: 2007, yearTo: 2014, engineCC: '1.0L'),
  CarModel(brand: 'Perodua', model: 'Kancil', bodyType: BodyType.hatchback, fuelConsumption: 4.3, passengerSeats: 4, yearFrom: 1994, yearTo: 2009, engineCC: '0.85L'),

  // ──────────── PROTON ────────────
  CarModel(brand: 'Proton', model: 'Saga', bodyType: BodyType.sedan, fuelConsumption: 5.8, passengerSeats: 4, yearFrom: 1985, engineCC: '1.3L'),
  CarModel(brand: 'Proton', model: 'Persona', bodyType: BodyType.sedan, fuelConsumption: 6.2, passengerSeats: 4, yearFrom: 2016, engineCC: '1.6L'),
  CarModel(brand: 'Proton', model: 'Iriz', bodyType: BodyType.hatchback, fuelConsumption: 5.6, passengerSeats: 4, yearFrom: 2014, engineCC: '1.6L'),
  CarModel(brand: 'Proton', model: 'S70', bodyType: BodyType.sedan, fuelConsumption: 5.9, passengerSeats: 4, yearFrom: 2023, engineCC: '1.5T'),
  CarModel(brand: 'Proton', model: 'X50', bodyType: BodyType.suv, fuelConsumption: 6.4, passengerSeats: 4, yearFrom: 2020, engineCC: '1.5T'),
  CarModel(brand: 'Proton', model: 'X70', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2018, engineCC: '1.5T'),
  CarModel(brand: 'Proton', model: 'X90', bodyType: BodyType.suv, fuelConsumption: 7.8, passengerSeats: 6, yearFrom: 2023, engineCC: '1.5T'),
  CarModel(brand: 'Proton', model: 'Exora', bodyType: BodyType.mpv, fuelConsumption: 7.2, passengerSeats: 6, yearFrom: 2009, yearTo: 2024, engineCC: '1.6T'),
  CarModel(brand: 'Proton', model: 'Wira', bodyType: BodyType.sedan, fuelConsumption: 7.5, passengerSeats: 4, yearFrom: 1993, yearTo: 2009, engineCC: '1.5L'),
  CarModel(brand: 'Proton', model: 'Waja', bodyType: BodyType.sedan, fuelConsumption: 7.8, passengerSeats: 4, yearFrom: 2000, yearTo: 2011, engineCC: '1.6L'),
  CarModel(brand: 'Proton', model: 'Satria Neo', bodyType: BodyType.hatchback, fuelConsumption: 6.5, passengerSeats: 4, yearFrom: 2006, yearTo: 2015, engineCC: '1.6L'),
  CarModel(brand: 'Proton', model: 'Preve', bodyType: BodyType.sedan, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2012, yearTo: 2018, engineCC: '1.6T'),
  CarModel(brand: 'Proton', model: 'Suprima S', bodyType: BodyType.hatchback, fuelConsumption: 6.8, passengerSeats: 4, yearFrom: 2013, yearTo: 2018, engineCC: '1.6T'),
  CarModel(brand: 'Proton', model: 'Perdana', bodyType: BodyType.sedan, fuelConsumption: 8.5, passengerSeats: 4, yearFrom: 2016, yearTo: 2020, engineCC: '2.0L'),
  CarModel(brand: 'Proton', model: 'Inspira', bodyType: BodyType.sedan, fuelConsumption: 7.2, passengerSeats: 4, yearFrom: 2010, yearTo: 2015, engineCC: '2.0L'),

  // ──────────── HONDA ────────────
  CarModel(brand: 'Honda', model: 'City', bodyType: BodyType.sedan, fuelConsumption: 5.7, passengerSeats: 4, yearFrom: 2003, engineCC: '1.5L'),
  CarModel(brand: 'Honda', model: 'City Hatchback', bodyType: BodyType.hatchback, fuelConsumption: 5.7, passengerSeats: 4, yearFrom: 2021, engineCC: '1.5L'),
  CarModel(brand: 'Honda', model: 'Civic', bodyType: BodyType.sedan, fuelConsumption: 6.5, passengerSeats: 4, yearFrom: 2005, engineCC: '1.5T'),
  CarModel(brand: 'Honda', model: 'Civic Type R', bodyType: BodyType.hatchback, fuelConsumption: 8.5, passengerSeats: 4, yearFrom: 2017, engineCC: '2.0T'),
  CarModel(brand: 'Honda', model: 'HR-V', bodyType: BodyType.suv, fuelConsumption: 6.3, passengerSeats: 4, yearFrom: 2015, engineCC: '1.5L'),
  CarModel(brand: 'Honda', model: 'CR-V', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2003, engineCC: '1.5T'),
  CarModel(brand: 'Honda', model: 'WR-V', bodyType: BodyType.suv, fuelConsumption: 5.9, passengerSeats: 4, yearFrom: 2023, engineCC: '1.5L'),
  CarModel(brand: 'Honda', model: 'BR-V', bodyType: BodyType.suv, fuelConsumption: 6.5, passengerSeats: 6, yearFrom: 2017, engineCC: '1.5L'),
  CarModel(brand: 'Honda', model: 'Jazz', bodyType: BodyType.hatchback, fuelConsumption: 5.5, passengerSeats: 4, yearFrom: 2003, yearTo: 2023, engineCC: '1.5L'),
  CarModel(brand: 'Honda', model: 'Accord', bodyType: BodyType.sedan, fuelConsumption: 6.8, passengerSeats: 4, yearFrom: 2003, engineCC: '1.5T'),

  // ──────────── TOYOTA ────────────
  CarModel(brand: 'Toyota', model: 'Vios', bodyType: BodyType.sedan, fuelConsumption: 5.8, passengerSeats: 4, yearFrom: 2003, engineCC: '1.5L'),
  CarModel(brand: 'Toyota', model: 'Yaris', bodyType: BodyType.hatchback, fuelConsumption: 5.5, passengerSeats: 4, yearFrom: 2019, engineCC: '1.5L'),
  CarModel(brand: 'Toyota', model: 'Yaris Ativ', bodyType: BodyType.sedan, fuelConsumption: 5.4, passengerSeats: 4, yearFrom: 2023, engineCC: '1.2L'),
  CarModel(brand: 'Toyota', model: 'Corolla', bodyType: BodyType.sedan, fuelConsumption: 6.0, passengerSeats: 4, yearFrom: 2019, engineCC: '1.8L'),
  CarModel(brand: 'Toyota', model: 'Camry', bodyType: BodyType.sedan, fuelConsumption: 6.5, passengerSeats: 4, yearFrom: 2003, engineCC: '2.5L'),
  CarModel(brand: 'Toyota', model: 'Veloz', bodyType: BodyType.mpv, fuelConsumption: 6.3, passengerSeats: 6, yearFrom: 2022, engineCC: '1.5L'),
  CarModel(brand: 'Toyota', model: 'Avanza', bodyType: BodyType.mpv, fuelConsumption: 6.5, passengerSeats: 6, yearFrom: 2004, yearTo: 2022, engineCC: '1.5L'),
  CarModel(brand: 'Toyota', model: 'Innova', bodyType: BodyType.mpv, fuelConsumption: 7.5, passengerSeats: 7, yearFrom: 2005, engineCC: '2.0L'),
  CarModel(brand: 'Toyota', model: 'Innova Zenix', bodyType: BodyType.mpv, fuelConsumption: 5.5, passengerSeats: 6, yearFrom: 2023, engineCC: '2.0L HEV'),
  CarModel(brand: 'Toyota', model: 'Rush', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 6, yearFrom: 2018, yearTo: 2022, engineCC: '1.5L'),
  CarModel(brand: 'Toyota', model: 'Corolla Cross', bodyType: BodyType.suv, fuelConsumption: 6.2, passengerSeats: 4, yearFrom: 2021, engineCC: '1.8L'),
  CarModel(brand: 'Toyota', model: 'RAV4', bodyType: BodyType.suv, fuelConsumption: 6.5, passengerSeats: 4, yearFrom: 2020, engineCC: '2.0L'),
  CarModel(brand: 'Toyota', model: 'Fortuner', bodyType: BodyType.suv, fuelConsumption: 8.5, passengerSeats: 6, yearFrom: 2005, engineCC: '2.8D'),
  CarModel(brand: 'Toyota', model: 'Hilux', bodyType: BodyType.pickup, fuelConsumption: 8.5, passengerSeats: 4, yearFrom: 2005, engineCC: '2.8D'),

  // ──────────── NISSAN ────────────
  CarModel(brand: 'Nissan', model: 'Almera', bodyType: BodyType.sedan, fuelConsumption: 5.8, passengerSeats: 4, yearFrom: 2012, engineCC: '1.0T'),
  CarModel(brand: 'Nissan', model: 'Almera Turbo', bodyType: BodyType.sedan, fuelConsumption: 5.3, passengerSeats: 4, yearFrom: 2020, engineCC: '1.0T'),
  CarModel(brand: 'Nissan', model: 'Kicks', bodyType: BodyType.suv, fuelConsumption: 5.1, passengerSeats: 4, yearFrom: 2022, engineCC: '1.2L e-POWER'),
  CarModel(brand: 'Nissan', model: 'X-Trail', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2015, engineCC: '1.5T e-POWER'),
  CarModel(brand: 'Nissan', model: 'Serena', bodyType: BodyType.mpv, fuelConsumption: 6.0, passengerSeats: 7, yearFrom: 2018, engineCC: '2.0L'),
  CarModel(brand: 'Nissan', model: 'Navara', bodyType: BodyType.pickup, fuelConsumption: 8.0, passengerSeats: 4, yearFrom: 2015, engineCC: '2.5D'),
  CarModel(brand: 'Nissan', model: 'Note', bodyType: BodyType.hatchback, fuelConsumption: 4.8, passengerSeats: 4, yearFrom: 2024, engineCC: '1.2L e-POWER'),

  // ──────────── MAZDA ────────────
  CarModel(brand: 'Mazda', model: '2 Sedan', bodyType: BodyType.sedan, fuelConsumption: 5.4, passengerSeats: 4, yearFrom: 2015, engineCC: '1.5L'),
  CarModel(brand: 'Mazda', model: '2 Hatchback', bodyType: BodyType.hatchback, fuelConsumption: 5.4, passengerSeats: 4, yearFrom: 2015, engineCC: '1.5L'),
  CarModel(brand: 'Mazda', model: '3 Sedan', bodyType: BodyType.sedan, fuelConsumption: 6.0, passengerSeats: 4, yearFrom: 2014, engineCC: '2.0L'),
  CarModel(brand: 'Mazda', model: '3 Hatchback', bodyType: BodyType.hatchback, fuelConsumption: 6.0, passengerSeats: 4, yearFrom: 2014, engineCC: '2.0L'),
  CarModel(brand: 'Mazda', model: 'CX-3', bodyType: BodyType.suv, fuelConsumption: 6.1, passengerSeats: 4, yearFrom: 2017, yearTo: 2023, engineCC: '2.0L'),
  CarModel(brand: 'Mazda', model: 'CX-30', bodyType: BodyType.suv, fuelConsumption: 6.3, passengerSeats: 4, yearFrom: 2020, engineCC: '2.0L'),
  CarModel(brand: 'Mazda', model: 'CX-5', bodyType: BodyType.suv, fuelConsumption: 6.8, passengerSeats: 4, yearFrom: 2012, engineCC: '2.0L'),
  CarModel(brand: 'Mazda', model: 'CX-8', bodyType: BodyType.suv, fuelConsumption: 6.5, passengerSeats: 6, yearFrom: 2019, yearTo: 2024, engineCC: '2.5T'),
  CarModel(brand: 'Mazda', model: 'CX-50', bodyType: BodyType.suv, fuelConsumption: 6.6, passengerSeats: 4, yearFrom: 2024, engineCC: '2.5L'),
  CarModel(brand: 'Mazda', model: 'CX-60', bodyType: BodyType.suv, fuelConsumption: 6.9, passengerSeats: 4, yearFrom: 2024, engineCC: '2.5L'),

  // ──────────── HYUNDAI ────────────
  CarModel(brand: 'Hyundai', model: 'Accent', bodyType: BodyType.sedan, fuelConsumption: 6.0, passengerSeats: 4, yearFrom: 2017, yearTo: 2020, engineCC: '1.4L'),
  CarModel(brand: 'Hyundai', model: 'Elantra', bodyType: BodyType.sedan, fuelConsumption: 6.3, passengerSeats: 4, yearFrom: 2016, yearTo: 2022, engineCC: '1.6L'),
  CarModel(brand: 'Hyundai', model: 'Kona', bodyType: BodyType.suv, fuelConsumption: 6.2, passengerSeats: 4, yearFrom: 2020, engineCC: '1.6T'),
  CarModel(brand: 'Hyundai', model: 'Tucson', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2016, engineCC: '1.6T'),
  CarModel(brand: 'Hyundai', model: 'Creta', bodyType: BodyType.suv, fuelConsumption: 6.0, passengerSeats: 4, yearFrom: 2024, engineCC: '1.5L'),
  CarModel(brand: 'Hyundai', model: 'Santa Fe', bodyType: BodyType.suv, fuelConsumption: 8.0, passengerSeats: 6, yearFrom: 2016, engineCC: '2.2D'),
  CarModel(brand: 'Hyundai', model: 'Stargazer', bodyType: BodyType.mpv, fuelConsumption: 6.0, passengerSeats: 6, yearFrom: 2023, engineCC: '1.5L'),
  CarModel(brand: 'Hyundai', model: 'Ioniq 5', bodyType: BodyType.suv, fuelConsumption: 1.8, passengerSeats: 4, yearFrom: 2022, engineCC: 'EV'),
  CarModel(brand: 'Hyundai', model: 'Ioniq 6', bodyType: BodyType.sedan, fuelConsumption: 1.5, passengerSeats: 4, yearFrom: 2024, engineCC: 'EV'),

  // ──────────── KIA ────────────
  CarModel(brand: 'Kia', model: 'Cerato', bodyType: BodyType.sedan, fuelConsumption: 6.2, passengerSeats: 4, yearFrom: 2016, yearTo: 2023, engineCC: '1.6L'),
  CarModel(brand: 'Kia', model: 'K3', bodyType: BodyType.sedan, fuelConsumption: 5.8, passengerSeats: 4, yearFrom: 2023, engineCC: '1.6L'),
  CarModel(brand: 'Kia', model: 'Sportage', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2016, engineCC: '1.6T'),
  CarModel(brand: 'Kia', model: 'Seltos', bodyType: BodyType.suv, fuelConsumption: 6.3, passengerSeats: 4, yearFrom: 2020, engineCC: '1.6L'),
  CarModel(brand: 'Kia', model: 'Carnival', bodyType: BodyType.mpv, fuelConsumption: 7.8, passengerSeats: 7, yearFrom: 2021, engineCC: '2.2D'),
  CarModel(brand: 'Kia', model: 'EV6', bodyType: BodyType.suv, fuelConsumption: 1.7, passengerSeats: 4, yearFrom: 2022, engineCC: 'EV'),
  CarModel(brand: 'Kia', model: 'EV9', bodyType: BodyType.suv, fuelConsumption: 2.0, passengerSeats: 6, yearFrom: 2024, engineCC: 'EV'),

  // ──────────── MITSUBISHI ────────────
  CarModel(brand: 'Mitsubishi', model: 'Triton', bodyType: BodyType.pickup, fuelConsumption: 7.8, passengerSeats: 4, yearFrom: 2005, engineCC: '2.4D'),
  CarModel(brand: 'Mitsubishi', model: 'Xpander', bodyType: BodyType.mpv, fuelConsumption: 6.5, passengerSeats: 6, yearFrom: 2020, engineCC: '1.5L'),
  CarModel(brand: 'Mitsubishi', model: 'ASX', bodyType: BodyType.suv, fuelConsumption: 6.5, passengerSeats: 4, yearFrom: 2011, yearTo: 2023, engineCC: '2.0L'),
  CarModel(brand: 'Mitsubishi', model: 'Outlander', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2016, engineCC: '2.4L'),
  CarModel(brand: 'Mitsubishi', model: 'Pajero Sport', bodyType: BodyType.suv, fuelConsumption: 8.0, passengerSeats: 6, yearFrom: 2016, yearTo: 2023, engineCC: '2.4D'),

  // ──────────── SUZUKI ────────────
  CarModel(brand: 'Suzuki', model: 'Swift', bodyType: BodyType.hatchback, fuelConsumption: 4.9, passengerSeats: 4, yearFrom: 2005, engineCC: '1.5L'),
  CarModel(brand: 'Suzuki', model: 'Swift Sport', bodyType: BodyType.hatchback, fuelConsumption: 5.6, passengerSeats: 4, yearFrom: 2019, yearTo: 2023, engineCC: '1.4T'),
  CarModel(brand: 'Suzuki', model: 'Jimny', bodyType: BodyType.suv, fuelConsumption: 6.8, passengerSeats: 3, yearFrom: 2019, engineCC: '1.5L'),
  CarModel(brand: 'Suzuki', model: 'Vitara', bodyType: BodyType.suv, fuelConsumption: 6.0, passengerSeats: 4, yearFrom: 2016, yearTo: 2022, engineCC: '1.6L'),
  CarModel(brand: 'Suzuki', model: 'Ertiga', bodyType: BodyType.mpv, fuelConsumption: 5.8, passengerSeats: 6, yearFrom: 2016, yearTo: 2020, engineCC: '1.5L'),

  // ──────────── SUBARU ────────────
  CarModel(brand: 'Subaru', model: 'XV', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2013, yearTo: 2023, engineCC: '2.0L'),
  CarModel(brand: 'Subaru', model: 'Crosstrek', bodyType: BodyType.suv, fuelConsumption: 6.8, passengerSeats: 4, yearFrom: 2023, engineCC: '2.0L'),
  CarModel(brand: 'Subaru', model: 'Forester', bodyType: BodyType.suv, fuelConsumption: 7.4, passengerSeats: 4, yearFrom: 2013, engineCC: '2.0L'),
  CarModel(brand: 'Subaru', model: 'Outback', bodyType: BodyType.suv, fuelConsumption: 7.8, passengerSeats: 4, yearFrom: 2016, engineCC: '2.5L'),
  CarModel(brand: 'Subaru', model: 'WRX', bodyType: BodyType.sedan, fuelConsumption: 8.5, passengerSeats: 4, yearFrom: 2016, engineCC: '2.4T'),
  CarModel(brand: 'Subaru', model: 'BRZ', bodyType: BodyType.sedan, fuelConsumption: 8.0, passengerSeats: 3, yearFrom: 2022, engineCC: '2.4L'),

  // ──────────── VOLKSWAGEN ────────────
  CarModel(brand: 'Volkswagen', model: 'Vento', bodyType: BodyType.sedan, fuelConsumption: 5.8, passengerSeats: 4, yearFrom: 2016, yearTo: 2021, engineCC: '1.2T'),
  CarModel(brand: 'Volkswagen', model: 'Polo', bodyType: BodyType.hatchback, fuelConsumption: 5.5, passengerSeats: 4, yearFrom: 2018, yearTo: 2021, engineCC: '1.6L'),
  CarModel(brand: 'Volkswagen', model: 'Golf', bodyType: BodyType.hatchback, fuelConsumption: 6.0, passengerSeats: 4, yearFrom: 2013, engineCC: '1.4T'),
  CarModel(brand: 'Volkswagen', model: 'Golf R', bodyType: BodyType.hatchback, fuelConsumption: 8.0, passengerSeats: 4, yearFrom: 2018, engineCC: '2.0T'),
  CarModel(brand: 'Volkswagen', model: 'Tiguan', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2017, engineCC: '1.4T'),
  CarModel(brand: 'Volkswagen', model: 'Passat', bodyType: BodyType.sedan, fuelConsumption: 6.5, passengerSeats: 4, yearFrom: 2017, engineCC: '2.0T'),

  // ──────────── BMW ────────────
  CarModel(brand: 'BMW', model: '1 Series', bodyType: BodyType.hatchback, fuelConsumption: 6.5, passengerSeats: 4, yearFrom: 2016, engineCC: '1.5T'),
  CarModel(brand: 'BMW', model: '2 Series Gran Coupe', bodyType: BodyType.sedan, fuelConsumption: 6.8, passengerSeats: 4, yearFrom: 2020, engineCC: '1.5T'),
  CarModel(brand: 'BMW', model: '3 Series', bodyType: BodyType.sedan, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2005, engineCC: '2.0T'),
  CarModel(brand: 'BMW', model: '5 Series', bodyType: BodyType.sedan, fuelConsumption: 7.5, passengerSeats: 4, yearFrom: 2005, engineCC: '2.0T'),
  CarModel(brand: 'BMW', model: 'X1', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2016, engineCC: '1.5T'),
  CarModel(brand: 'BMW', model: 'X3', bodyType: BodyType.suv, fuelConsumption: 7.5, passengerSeats: 4, yearFrom: 2017, engineCC: '2.0T'),
  CarModel(brand: 'BMW', model: 'X5', bodyType: BodyType.suv, fuelConsumption: 8.5, passengerSeats: 4, yearFrom: 2014, engineCC: '3.0T'),
  CarModel(brand: 'BMW', model: 'iX', bodyType: BodyType.suv, fuelConsumption: 2.1, passengerSeats: 4, yearFrom: 2022, engineCC: 'EV'),

  // ──────────── MERCEDES-BENZ ────────────
  CarModel(brand: 'Mercedes-Benz', model: 'A-Class Sedan', bodyType: BodyType.sedan, fuelConsumption: 6.5, passengerSeats: 4, yearFrom: 2019, engineCC: '1.3T'),
  CarModel(brand: 'Mercedes-Benz', model: 'C-Class', bodyType: BodyType.sedan, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2007, engineCC: '1.5T'),
  CarModel(brand: 'Mercedes-Benz', model: 'E-Class', bodyType: BodyType.sedan, fuelConsumption: 7.5, passengerSeats: 4, yearFrom: 2007, engineCC: '2.0T'),
  CarModel(brand: 'Mercedes-Benz', model: 'GLA', bodyType: BodyType.suv, fuelConsumption: 7.0, passengerSeats: 4, yearFrom: 2015, engineCC: '1.3T'),
  CarModel(brand: 'Mercedes-Benz', model: 'GLB', bodyType: BodyType.suv, fuelConsumption: 7.2, passengerSeats: 6, yearFrom: 2020, engineCC: '1.3T'),
  CarModel(brand: 'Mercedes-Benz', model: 'GLC', bodyType: BodyType.suv, fuelConsumption: 7.5, passengerSeats: 4, yearFrom: 2016, engineCC: '2.0T'),
  CarModel(brand: 'Mercedes-Benz', model: 'EQA', bodyType: BodyType.suv, fuelConsumption: 1.8, passengerSeats: 4, yearFrom: 2022, engineCC: 'EV'),
  CarModel(brand: 'Mercedes-Benz', model: 'EQB', bodyType: BodyType.suv, fuelConsumption: 2.0, passengerSeats: 6, yearFrom: 2022, engineCC: 'EV'),
];

/// Get all models for a specific brand.
List<CarModel> getModelsForBrand(String brand) {
  return malaysiaCarDatabase
      .where((car) => car.brand == brand)
      .toList();
}

/// Get only currently available (on-sale) models for a brand.
List<CarModel> getCurrentModelsForBrand(String brand) {
  return malaysiaCarDatabase
      .where((car) => car.brand == brand && car.isCurrentlyOnSale)
      .toList();
}

/// Search across all models by name (fuzzy).
List<CarModel> searchCars(String query) {
  final q = query.toLowerCase();
  return malaysiaCarDatabase
      .where((car) =>
          car.displayName.toLowerCase().contains(q) ||
          car.model.toLowerCase().contains(q) ||
          car.brand.toLowerCase().contains(q))
      .toList();
}
