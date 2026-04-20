import 'package:flutter/material.dart';
import 'package:germana/data/mock_rides_peninsular.dart';
import 'package:germana/models/ride_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { passenger, driver, both }

enum PersonSex { male, female }

enum DriverListingStatus { draft, published, paused, inProgress, completed, cancelled }

enum RideRequestStatus { pending, accepted, rejected }

enum BookingOutcome { booked, pendingApproval, full }

class RideJoinRequest {
  final String id;
  final String passengerName;
  final DateTime requestedAt;
  final RideRequestStatus status;

  const RideJoinRequest({
    required this.id,
    required this.passengerName,
    required this.requestedAt,
    this.status = RideRequestStatus.pending,
  });

  RideJoinRequest copyWith({
    String? id,
    String? passengerName,
    DateTime? requestedAt,
    RideRequestStatus? status,
  }) {
    return RideJoinRequest(
      id: id ?? this.id,
      passengerName: passengerName ?? this.passengerName,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
    );
  }
}

class DriverManagedRide {
  final RideModel ride;
  final int seatsLeft;
  final DriverListingStatus status;
  final List<RideJoinRequest> requests;

  const DriverManagedRide({
    required this.ride,
    required this.seatsLeft,
    this.status = DriverListingStatus.published,
    this.requests = const <RideJoinRequest>[],
  });

  RideModel get resolvedRide => ride.copyWith(seatsLeft: seatsLeft);

  DriverManagedRide copyWith({
    RideModel? ride,
    int? seatsLeft,
    DriverListingStatus? status,
    List<RideJoinRequest>? requests,
  }) {
    return DriverManagedRide(
      ride: ride ?? this.ride,
      seatsLeft: seatsLeft ?? this.seatsLeft,
      status: status ?? this.status,
      requests: requests ?? this.requests,
    );
  }
}

/// Centralized app state — profile data, theme mode, and ride state.
/// Injected via InheritedWidget so all screens can read/write.
class AppState extends ChangeNotifier {
  bool _isHydrated = false;
  bool get isHydrated => _isHydrated;

  static const _kThemeMode = 'theme_mode';
  static const _kIsAuthenticated = 'is_authenticated';
  static const _kIsProfileComplete = 'is_profile_complete';
  static const _kLocationPermission = 'location_permission_granted';
  static const _kNotificationPermission = 'notification_permission_granted';
  static const _kName = 'profile_name';
  static const _kFaculty = 'profile_faculty';
  static const _kEmail = 'profile_email';
  static const _kPhone = 'profile_phone';
  static const _kSex = 'profile_sex';
  static const _kCarModel = 'car_model';
  static const _kCarPlate = 'car_plate';
  static const _kCarColor = 'car_color';
  static const _kCarFuelConsumption = 'car_fuel_consumption';
  static const _kCurrentLocationLabel = 'current_location_label';
  static const _kCurrentLocationLat = 'current_location_lat';
  static const _kCurrentLocationLng = 'current_location_lng';
  static const _kUserRole = 'user_role';
  static const _kLocaleCode = 'locale_code';

  // --- Auth & onboarding ---
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isProfileComplete = false;
  bool get isProfileComplete => _isProfileComplete;

  bool _locationPermissionGranted = false;
  bool get locationPermissionGranted => _locationPermissionGranted;

  bool _notificationPermissionGranted = false;
  bool get notificationPermissionGranted => _notificationPermissionGranted;

  String _emailDomain = 'smail.unikl.edu.my';
  String get emailDomain => _emailDomain;

  UserRole _userRole = UserRole.both;
  UserRole get userRole => _userRole;

  String _currentLocationLabel = 'UniKL MIIT, Gombak';
  String get currentLocationLabel => _currentLocationLabel;
  double _currentLocationLat = 3.2078;
  double get currentLocationLat => _currentLocationLat;
  double _currentLocationLng = 101.7282;
  double get currentLocationLng => _currentLocationLng;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  // --- Theme ---
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _persist();
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

  PersonSex _sex = PersonSex.male;
  PersonSex get sex => _sex;

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

  int _idCounter = DateTime.now().millisecondsSinceEpoch % 1000000;
  final List<DriverManagedRide> _driverManagedRides = <DriverManagedRide>[];
  List<DriverManagedRide> get driverManagedRides => List<DriverManagedRide>.unmodifiable(_driverManagedRides);

  final List<RideModel> _passengerBookedRides = <RideModel>[];
  List<RideModel> get passengerBookedRides => List<RideModel>.unmodifiable(_passengerBookedRides);

  final Map<String, int> _marketSeatOverrides = <String, int>{};

  // --- Auth & permission mutators ---
  bool canSignInWithEmail(String email) {
    return email.trim().toLowerCase().endsWith('@$emailDomain');
  }

  bool signIn(String email) {
    if (!canSignInWithEmail(email)) return false;
    _email = email.trim().toLowerCase();
    _isAuthenticated = true;
    notifyListeners();
    _persist();
    return true;
  }

  void signOut() {
    _isAuthenticated = false;
    _isProfileComplete = false;
    _locationPermissionGranted = false;
    _notificationPermissionGranted = false;
    notifyListeners();
    _persist();
  }

  void setProfileComplete(bool isComplete) {
    _isProfileComplete = isComplete;
    notifyListeners();
    _persist();
  }

  bool get hasRequiredPermissions {
    return _locationPermissionGranted && _notificationPermissionGranted;
  }

  void setPermissions({
    bool? location,
    bool? notifications,
  }) {
    if (location != null) _locationPermissionGranted = location;
    if (notifications != null) _notificationPermissionGranted = notifications;
    notifyListeners();
    _persist();
  }

  void setUserRole(UserRole role) {
    _userRole = role;
    notifyListeners();
    _persist();
  }

  void setCurrentLocationLabel(String label) {
    _currentLocationLabel = label;
    notifyListeners();
    _persist();
  }

  void setCurrentLocation({
    required String label,
    required double lat,
    required double lng,
  }) {
    _currentLocationLabel = label;
    _currentLocationLat = lat;
    _currentLocationLng = lng;
    notifyListeners();
    _persist();
  }

  void setLocale(Locale locale) {
    _locale = Locale(locale.languageCode);
    notifyListeners();
    _persist();
  }

  // --- Mutators ---
  void updateProfile({
    String? name,
    String? faculty,
    String? email,
    String? phone,
    PersonSex? sex,
  }) {
    if (name != null) _name = name;
    if (faculty != null) _faculty = faculty;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    if (sex != null) _sex = sex;
    notifyListeners();
    _persist();
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
    _persist();
  }

  void incrementRides() {
    _totalRides++;
    notifyListeners();
    _persist();
  }

  String _nextId(String prefix) {
    _idCounter += 1;
    return '${prefix}_$_idCounter';
  }

  List<RideModel> marketplaceRides(List<RideModel> seedRides) {
    final now = DateTime.now();
    final merged = seedRides.map((ride) {
      final seats = _marketSeatOverrides[ride.id];
      if (seats == null) return ride;
      return ride.copyWith(seatsLeft: seats);
    }).where((ride) => ride.seatsLeft > 0).toList();

    for (final managed in _driverManagedRides) {
      final active = managed.status == DriverListingStatus.published;
      final notDeparted = managed.ride.departureTime.isAfter(now.subtract(const Duration(minutes: 10)));
      if (active && managed.seatsLeft > 0 && notDeparted) {
        merged.add(managed.resolvedRide);
      }
    }

    merged.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    return merged;
  }

  void publishDriverRide(RideModel ride) {
    final managed = DriverManagedRide(
      ride: ride,
      seatsLeft: ride.seatsLeft,
      status: DriverListingStatus.published,
    );
    _driverManagedRides.insert(0, managed);
    _ridesAsDriver += 1;
    notifyListeners();
  }

  void setDriverRideStatus({
    required String rideId,
    required DriverListingStatus status,
  }) {
    final index = _driverManagedRides.indexWhere((r) => r.ride.id == rideId);
    if (index == -1) return;
    _driverManagedRides[index] = _driverManagedRides[index].copyWith(status: status);
    notifyListeners();
  }

  String addJoinRequest({
    required String rideId,
    required String passengerName,
  }) {
    final index = _driverManagedRides.indexWhere((r) => r.ride.id == rideId);
    if (index == -1) return '';

    final managed = _driverManagedRides[index];
    final request = RideJoinRequest(
      id: _nextId('req'),
      passengerName: passengerName,
      requestedAt: DateTime.now(),
      status: RideRequestStatus.pending,
    );

    _driverManagedRides[index] = managed.copyWith(
      requests: <RideJoinRequest>[request, ...managed.requests],
    );
    notifyListeners();
    return request.id;
  }

  void acceptJoinRequest({
    required String rideId,
    required String requestId,
  }) {
    final rideIndex = _driverManagedRides.indexWhere((r) => r.ride.id == rideId);
    if (rideIndex == -1) return;

    final managed = _driverManagedRides[rideIndex];
    final reqIndex = managed.requests.indexWhere((r) => r.id == requestId);
    if (reqIndex == -1 || managed.seatsLeft <= 0) return;
    if (managed.requests[reqIndex].status != RideRequestStatus.pending) return;

    final updatedRequests = List<RideJoinRequest>.from(managed.requests);
    updatedRequests[reqIndex] = updatedRequests[reqIndex].copyWith(
      status: RideRequestStatus.accepted,
    );

    final nextSeats = managed.seatsLeft - 1;
    _driverManagedRides[rideIndex] = managed.copyWith(
      seatsLeft: nextSeats,
      requests: updatedRequests,
    );
    _marketSeatOverrides[rideId] = nextSeats;

    _passengerBookedRides.insert(
      0,
      managed.ride.copyWith(
        seatsLeft: nextSeats,
        isBooked: true,
        driverName: managed.ride.driverDisplayName,
        carPlate: managed.ride.carPlate ?? carPlate,
      ),
    );
    notifyListeners();
  }

  void rejectJoinRequest({
    required String rideId,
    required String requestId,
  }) {
    final rideIndex = _driverManagedRides.indexWhere((r) => r.ride.id == rideId);
    if (rideIndex == -1) return;

    final managed = _driverManagedRides[rideIndex];
    final reqIndex = managed.requests.indexWhere((r) => r.id == requestId);
    if (reqIndex == -1) return;
    if (managed.requests[reqIndex].status != RideRequestStatus.pending) return;

    final updatedRequests = List<RideJoinRequest>.from(managed.requests);
    updatedRequests[reqIndex] = updatedRequests[reqIndex].copyWith(
      status: RideRequestStatus.rejected,
    );

    _driverManagedRides[rideIndex] = managed.copyWith(requests: updatedRequests);
    notifyListeners();
  }

  BookingOutcome confirmPassengerBooking(RideModel ride) {
    final managedIndex = _driverManagedRides.indexWhere((r) => r.ride.id == ride.id);
    if (managedIndex != -1) {
      final managed = _driverManagedRides[managedIndex];
      if (managed.seatsLeft <= 0 || managed.status != DriverListingStatus.published) {
        return BookingOutcome.full;
      }
      addJoinRequest(rideId: ride.id, passengerName: name);
      return BookingOutcome.pendingApproval;
    }

    final currentSeats = _marketSeatOverrides[ride.id] ?? ride.seatsLeft;
    if (currentSeats <= 0) return BookingOutcome.full;

    final nextSeats = currentSeats - 1;
    _marketSeatOverrides[ride.id] = nextSeats;
    _passengerBookedRides.insert(
      0,
      ride.copyWith(
        seatsLeft: nextSeats,
        isBooked: true,
        driverName: ride.driverDisplayName,
        carPlate: ride.carPlate ?? 'WXY 1234',
      ),
    );
    notifyListeners();
    return BookingOutcome.booked;
  }

  bool get hasSeededDriverScenario =>
      _driverManagedRides.any((r) => r.ride.id.startsWith('seed_driver_'));

  void seedDriverTestingScenario() {
    if (hasSeededDriverScenario) return;

    final base = mockRidesPeninsular.first.copyWith(
      id: 'seed_driver_${DateTime.now().millisecondsSinceEpoch}',
      origin: currentLocationLabel,
      pickupAddress: currentLocationLabel,
      pickupLat: currentLocationLat,
      pickupLng: currentLocationLng,
      departureTime: DateTime.now().add(const Duration(minutes: 55)),
      driverAlias: 'Verified Driver - $faculty',
      driverSex: _sex == PersonSex.female ? DriverSex.female : DriverSex.male,
      driverName: _name,
      carModel: _carModel,
      carPlate: _carPlate,
      totalSeats: 4,
      seatsLeft: 3,
      isBooked: false,
    );

    final seeded = DriverManagedRide(
      ride: base,
      seatsLeft: 3,
      status: DriverListingStatus.published,
      requests: <RideJoinRequest>[
        RideJoinRequest(
          id: _nextId('req'),
          passengerName: 'Student Aisyah',
          requestedAt: DateTime.now().subtract(const Duration(minutes: 7)),
          status: RideRequestStatus.pending,
        ),
        RideJoinRequest(
          id: _nextId('req'),
          passengerName: 'Student Firdaus',
          requestedAt: DateTime.now().subtract(const Duration(minutes: 15)),
          status: RideRequestStatus.accepted,
        ),
      ],
    );

    _driverManagedRides.insert(0, seeded);
    notifyListeners();
  }

  void clearSeededDriverScenario() {
    _driverManagedRides.removeWhere((r) => r.ride.id.startsWith('seed_driver_'));
    notifyListeners();
  }

  Future<void> hydrate() async {
    if (_isHydrated) return;
    final prefs = await SharedPreferences.getInstance();

    _themeMode = _themeModeFromString(prefs.getString(_kThemeMode));
    _isAuthenticated = prefs.getBool(_kIsAuthenticated) ?? _isAuthenticated;
    _isProfileComplete =
        prefs.getBool(_kIsProfileComplete) ?? _isProfileComplete;
    _locationPermissionGranted =
        prefs.getBool(_kLocationPermission) ?? _locationPermissionGranted;
    _notificationPermissionGranted =
        prefs.getBool(_kNotificationPermission) ?? _notificationPermissionGranted;

    _name = prefs.getString(_kName) ?? _name;
    _faculty = prefs.getString(_kFaculty) ?? _faculty;
    _email = prefs.getString(_kEmail) ?? _email;
    _phone = prefs.getString(_kPhone) ?? _phone;
    _sex = _sexFromString(prefs.getString(_kSex));

    _carModel = prefs.getString(_kCarModel) ?? _carModel;
    _carPlate = prefs.getString(_kCarPlate) ?? _carPlate;
    _carColor = prefs.getString(_kCarColor) ?? _carColor;
    _carFuelConsumption =
        prefs.getDouble(_kCarFuelConsumption) ?? _carFuelConsumption;

    _currentLocationLabel =
        prefs.getString(_kCurrentLocationLabel) ?? _currentLocationLabel;
    _currentLocationLat =
      prefs.getDouble(_kCurrentLocationLat) ?? _currentLocationLat;
    _currentLocationLng =
      prefs.getDouble(_kCurrentLocationLng) ?? _currentLocationLng;
    _userRole = _roleFromString(prefs.getString(_kUserRole));
    _locale = Locale(prefs.getString(_kLocaleCode) ?? _locale.languageCode);

    _isHydrated = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    if (!_isHydrated) return;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_kThemeMode, _themeMode.name);
    await prefs.setBool(_kIsAuthenticated, _isAuthenticated);
    await prefs.setBool(_kIsProfileComplete, _isProfileComplete);
    await prefs.setBool(_kLocationPermission, _locationPermissionGranted);
    await prefs.setBool(_kNotificationPermission, _notificationPermissionGranted);

    await prefs.setString(_kName, _name);
    await prefs.setString(_kFaculty, _faculty);
    await prefs.setString(_kEmail, _email);
    await prefs.setString(_kPhone, _phone);
    await prefs.setString(_kSex, _sex.name);

    await prefs.setString(_kCarModel, _carModel);
    await prefs.setString(_kCarPlate, _carPlate);
    await prefs.setString(_kCarColor, _carColor);
    await prefs.setDouble(_kCarFuelConsumption, _carFuelConsumption);

    await prefs.setString(_kCurrentLocationLabel, _currentLocationLabel);
    await prefs.setDouble(_kCurrentLocationLat, _currentLocationLat);
    await prefs.setDouble(_kCurrentLocationLng, _currentLocationLng);
    await prefs.setString(_kUserRole, _userRole.name);
    await prefs.setString(_kLocaleCode, _locale.languageCode);
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  PersonSex _sexFromString(String? value) {
    return value == PersonSex.female.name ? PersonSex.female : PersonSex.male;
  }

  UserRole _roleFromString(String? value) {
    switch (value) {
      case 'passenger':
        return UserRole.passenger;
      case 'driver':
        return UserRole.driver;
      default:
        return UserRole.both;
    }
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
