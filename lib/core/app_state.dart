import 'package:flutter/material.dart';

/// Centralized app state — profile data, theme mode, and ride state.
/// Injected via InheritedWidget so all screens can read/write.
class AppState extends ChangeNotifier {
  // --- Theme ---
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // --- Profile ---
  String _name = 'Aminnur';
  String get name => _name;
  String get initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return _name.isNotEmpty ? _name[0].toUpperCase() : '?';
  }

  String _faculty = 'UniKL MIIT';
  String get faculty => _faculty;

  String _email = 'aminnur@smail.unikl.edu.my';
  String get email => _email;

  String _phone = '+60 11-1234 5678';
  String get phone => _phone;

  // Car profile
  String _carModel = 'Perodua Myvi';
  String get carModel => _carModel;

  String _carPlate = 'WXY 1234';
  String get carPlate => _carPlate;

  String _carColor = 'Putih';
  String get carColor => _carColor;

  double _carFuelConsumption = 6.2; // L/100km
  double get carFuelConsumption => _carFuelConsumption;

  // Stats (mock but trackable)
  int _totalRides = 12;
  int get totalRides => _totalRides;

  double _rating = 4.9;
  double get rating => _rating;

  int _ridesAsDriver = 3;
  int get ridesAsDriver => _ridesAsDriver;

  // --- Mutators ---
  void updateProfile({
    String? name,
    String? faculty,
    String? email,
    String? phone,
  }) {
    if (name != null) _name = name;
    if (faculty != null) _faculty = faculty;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    notifyListeners();
  }

  void updateCar({
    String? model,
    String? plate,
    String? color,
    double? fuelConsumption,
  }) {
    if (model != null) _carModel = model;
    if (plate != null) _carPlate = plate;
    if (color != null) _carColor = color;
    if (fuelConsumption != null) _carFuelConsumption = fuelConsumption;
    notifyListeners();
  }

  void incrementRides() {
    _totalRides++;
    notifyListeners();
  }
}

/// InheritedWidget provider for AppState.
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
        .notifier!;
  }
}
