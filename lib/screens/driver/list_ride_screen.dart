import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/data/car_database.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/screens/explore/places_search_screen.dart';
import 'package:germana/services/fair_rate_service.dart';
import 'package:germana/services/location_service.dart';
import 'package:germana/services/malaysia_fuel_price_service.dart';
import 'package:germana/widgets/glass_text_field.dart';
import 'package:germana/widgets/pill_button.dart';
import 'package:germana/widgets/ride_map_snippet.dart';
import 'package:intl/intl.dart';

/// Comprehensive driver flow for publishing a ride.
class ListRideScreen extends StatefulWidget {
  const ListRideScreen({super.key});

  @override
  State<ListRideScreen> createState() => _ListRideScreenState();
}

class _ListRideScreenState extends State<ListRideScreen> {
  final LocationService _locationService = LocationService();
  final FairRateService _fairRateService = FairRateService();
  final MalaysiaFuelPriceService _fuelPriceService = MalaysiaFuelPriceService();

  PlaceDetails? _origin;
  PlaceDetails? _destination;
  final List<PlaceDetails> _pickupPoints = <PlaceDetails>[];

  RouteDetails? _routeDetails;
  bool _isCalculatingRoute = false;
  bool _didInitFromState = false;

  int _selectedCar = 0;
  int _maxPickupPoints = 2;
  int _seatCount = 4;
  DateTime _departure = DateTime.now().add(const Duration(hours: 1));

  late final TextEditingController _plateController;
  late final TextEditingController _customCarController;
  late final TextEditingController _customFareController;
  late final TextEditingController _reasonController;
  bool _useSelectedCarPlate = true;
  bool _useCustomCarName = false;

  bool _submitAttempted = false;
  bool _listed = false;
  int _activeStep = 0;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController();
    _customCarController = TextEditingController();
    _customFareController = TextEditingController();
    _reasonController = TextEditingController();
    
    _customFareController.addListener(() {
      if (mounted) setState(() {});
    });

    _syncFuelPrices();
  }

  Future<void> _syncFuelPrices() async {
    await _fuelPriceService.syncFromRemoteIfConfigured();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitFromState) return;

    final state = AppStateProvider.of(context);
    _origin = PlaceDetails(
      lat: state.currentLocationLat,
      lng: state.currentLocationLng,
      name: state.currentLocationLabel,
      address: state.currentLocationLabel,
    );
    _plateController.text = state.carPlate;
    _didInitFromState = true;
  }

  @override
  void dispose() {
    _plateController.dispose();
    _customCarController.dispose();
    _customFareController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getCars(AppState state) => [
        {
          'name': state.carModel,
          'fuel': state.carFuelConsumption,
          'plate': state.carPlate,
          'fuelType': FuelType.ron95,
          'seats': _resolveSeatsForModel(state.carModel, 4),
        },
        {
          'name': 'Perodua Axia',
          'fuel': 5.8,
          'plate': 'ABC 5678',
          'fuelType': FuelType.ron95,
          'seats': _resolveSeatsForModel('Perodua Axia', 4),
        },
        {
          'name': 'Honda City',
          'fuel': 7.0,
          'plate': 'DEF 9012',
          'fuelType': FuelType.ron97,
          'seats': _resolveSeatsForModel('Honda City', 4),
        },
      ];

  int _resolveSeatsForModel(String modelName, int fallback) {
    final normalized = modelName.trim().toLowerCase();
    final matches = malaysiaCarDatabase.where(
      (car) => car.displayName.toLowerCase() == normalized,
    );
    if (matches.isNotEmpty) return matches.first.passengerSeats;
    return fallback;
  }

  int _selectedCarSeatCap(List<Map<String, dynamic>> cars) {
    final dynamic raw = cars[_selectedCar]['seats'];
    if (raw is int) return raw.clamp(1, 7);
    if (raw is num) return raw.toInt().clamp(1, 7);
    return 6;
  }

  FuelType _selectedFuelType(List<Map<String, dynamic>> cars) {
    return (cars[_selectedCar]['fuelType'] as FuelType?) ?? FuelType.ron95;
  }

  FairRateBreakdown? _pricingFor(List<Map<String, dynamic>> cars) {
    if (_routeDetails == null) return null;

    final selectedFuelType = _selectedFuelType(cars);
    final fuelPrice = _fuelPriceService.currentPrice(selectedFuelType);
    final toll = _routeDetails!.estimatedTollRm > 0
        ? _routeDetails!.estimatedTollRm
        : LocationService.estimateTollRm(_routeDetails!.distanceKm);

    return _fairRateService.calculate(
      FairRateInput(
        distanceKm: _routeDetails!.distanceKm,
        fuelConsumptionLPer100Km: (cars[_selectedCar]['fuel'] as double),
        fuelPricePerLiter: fuelPrice,
        seats: _seatCount,
        tollRm: toll,
      ),
    );
  }

  String _fuelPriceLabel(List<Map<String, dynamic>> cars) {
    final fuelType = _selectedFuelType(cars);
    final price = _fuelPriceService.currentPrice(fuelType);
    final trend = _fuelPriceService.trendLabel(fuelType);
    final updated = _fuelPriceService.lastUpdated();
    final trendIcon = trend == 'up'
        ? '↑'
        : trend == 'down'
            ? '↓'
            : '→';
    return '${_fuelPriceService.label(fuelType)} RM ${price.toStringAsFixed(2)}/L $trendIcon · ${DateFormat('d MMM').format(updated)}';
  }

  double _perSeat(List<Map<String, dynamic>> cars) {
    final pricing = _pricingFor(cars);
    return pricing?.perSeatRecommendedRm ?? 0.0;
  }

  bool get _canAddPickup => _pickupPoints.length < _maxPickupPoints;

  bool get _isPlateValid {
    final value = _plateController.text.trim();
    if (value.isEmpty) return false;
    final regex = RegExp(r'^[A-Za-z]{1,3}\s?[A-Za-z]?\s?\d{1,4}$');
    return regex.hasMatch(value);
  }

  String _activeCarName(List<Map<String, dynamic>> cars) {
    if (_useCustomCarName) {
      final custom = _customCarController.text.trim();
      if (custom.isNotEmpty) return custom;
    }
    return cars[_selectedCar]['name'] as String;
  }

  Future<void> _pickOrigin(AppLocalizations l10n) async {
    final result = await Navigator.of(context).push<PlaceDetails>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => PlacesSearchScreen(
          hint: l10n.fromWhereHint,
          initialValue: _origin?.name,
        ),
        transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
      ),
    );
    if (result != null) {
      setState(() => _origin = result);
      _calculateRoute();
    }
  }

  Future<void> _pickDestination(AppLocalizations l10n) async {
    final result = await Navigator.of(context).push<PlaceDetails>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => PlacesSearchScreen(
          hint: l10n.toWhereHint,
          initialValue: _destination?.name,
        ),
        transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
      ),
    );
    if (result != null) {
      setState(() => _destination = result);
      _calculateRoute();
    }
  }

  Future<void> _addPickupPoint() async {
    if (!_canAddPickup) return;

    final result = await Navigator.of(context).push<PlaceDetails>(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const PlacesSearchScreen(
          hint: 'Pickup point',
        ),
        transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
      ),
    );

    if (result != null) {
      setState(() => _pickupPoints.add(result));
    }
  }

  Future<void> _pickDepartureDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _departure.isAfter(now) ? _departure : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departure),
    );
    if (time == null) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _departure = picked.isBefore(now)
          ? now.add(const Duration(minutes: 10))
          : picked;
    });
  }

  String? _validateDraft(List<Map<String, dynamic>> cars) {
    if (_origin == null) return 'Choose a start location.';
    if (_destination == null) return 'Choose a destination.';
    if (_origin!.lat == _destination!.lat &&
        _origin!.lng == _destination!.lng) {
      return 'Origin and destination cannot be the same point.';
    }
    if (_pickupPoints.length > _maxPickupPoints) {
      return 'Pickup points exceed allowed limit.';
    }
    if (_seatCount < 1 || _seatCount > 6) {
      return 'Seat count must be between 1 and 6.';
    }
    final seatCap = _selectedCarSeatCap(cars);
    if (_seatCount > seatCap) {
      return 'Selected car supports up to $seatCap passenger seats.';
    }

    if (_useCustomCarName && _customCarController.text.trim().isEmpty) {
      return 'Enter a custom car model or turn off custom mode.';
    }

    if (_useSelectedCarPlate) {
      _plateController.text = cars[_selectedCar]['plate'] as String;
    }
    if (!_isPlateValid) {
      return 'Enter a valid license plate (example: WXY 1234).';
    }

    return null;
  }

  void _onPublish(List<Map<String, dynamic>> cars) {
    setState(() => _submitAttempted = true);
    final validationError = _validateDraft(cars);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    final state = AppStateProvider.of(context);
    final pricing = _pricingFor(cars);
    final fallbackDistance = _routeDetails?.distanceKm ?? 0;
    final fallbackToll = _routeDetails?.estimatedTollRm ?? 0;
    final fuelRm = pricing?.fuelRm ?? 0;
    final tollRm = pricing?.tollRm ?? fallbackToll;
    const platformFee = 1.0;

    double? parsedDriverFare;
    if (_customFareController.text.trim().isNotEmpty) {
      parsedDriverFare = double.tryParse(_customFareController.text.trim());
    }
    final driverFareReason = _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim();

    final driverSex = state.sex == PersonSex.female ? DriverSex.female : DriverSex.male;

    final ride = RideModel(
      id: 'drv_${DateTime.now().millisecondsSinceEpoch}',
      origin: _origin!.name,
      destination: _destination!.name,
      destinationLat: _destination!.lat,
      destinationLng: _destination!.lng,
      pickupAddress: _origin!.address,
      pickupLat: _origin!.lat,
      pickupLng: _origin!.lng,
      distanceKm: fallbackDistance,
      driverAlias: 'Verified Driver - ${state.faculty}',
      driverSex: driverSex,
      driverName: state.name,
      carPlate: _plateController.text.trim(),
      carModel: _activeCarName(cars),
      departureTime: _departure,
      totalSeats: _seatCount,
      seatsLeft: _seatCount,
      fuelShare: fuelRm,
      tollShare: tollRm,
      platformFee: platformFee,
      driverFare: parsedDriverFare,
      fareReason: driverFareReason,
    );
    state.publishDriverRide(ride);

    setState(() => _listed = true);
  }

  String? _validateJourneyStep() {
    if (_origin == null) return 'Choose a start location.';
    if (_destination == null) return 'Choose a destination.';
    if (_origin!.lat == _destination!.lat && _origin!.lng == _destination!.lng) {
      return 'Origin and destination cannot be the same point.';
    }
    return null;
  }

  String? _validateVehicleStep(List<Map<String, dynamic>> cars) {
    if (_seatCount < 1 || _seatCount > 6) {
      return 'Seat count must be between 1 and 6.';
    }

    final seatCap = _selectedCarSeatCap(cars);
    if (_seatCount > seatCap) {
      return 'Selected car supports up to $seatCap passenger seats.';
    }

    if (_useCustomCarName && _customCarController.text.trim().isEmpty) {
      return 'Enter a custom car model or turn off custom mode.';
    }

    if (_useSelectedCarPlate) {
      _plateController.text = cars[_selectedCar]['plate'] as String;
    }
    if (!_isPlateValid) {
      return 'Enter a valid license plate (example: WXY 1234).';
    }

    final pricing = _pricingFor(cars);
    if (pricing != null) {
      final customFareText = _customFareController.text.trim();
      if (customFareText.isNotEmpty) {
        final customFare = double.tryParse(customFareText);
        if (customFare == null || customFare <= 0) {
          return 'Enter a valid fare amount.';
        }
        final cap = pricing.perSeatRecommendedRm * 1.15;
        if (customFare > cap && _reasonController.text.trim().isEmpty) {
          return 'Please provide a reason for the fare above +15%.';
        }
      } else {
        return 'Please set a fare per seat.';
      }
    }

    return null;
  }

  String? _validateStep(int step, List<Map<String, dynamic>> cars) {
    switch (step) {
      case 0:
        return _validateJourneyStep();
      case 1:
        return _validateVehicleStep(cars);
      case 2:
      default:
        return _validateDraft(cars);
    }
  }

  void _goNextStep(List<Map<String, dynamic>> cars) {
    final error = _validateStep(_activeStep, cars);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_activeStep < 2) {
      setState(() {
        _activeStep += 1;
        if (_activeStep == 1 && _customFareController.text.isEmpty) {
          final pricing = _pricingFor(cars);
          if (pricing != null) {
            _customFareController.text = pricing.perSeatRecommendedRm.toStringAsFixed(2);
          }
        }
      });
    }
  }

  void _goPreviousStep() {
    if (_activeStep > 0) {
      setState(() => _activeStep -= 1);
    }
  }

  Future<void> _calculateRoute() async {
    if (_origin != null && _destination != null) {
      setState(() => _isCalculatingRoute = true);
      final details = await _locationService.getDirections(_origin!, _destination!);
      if (!mounted) return;
      setState(() {
        _routeDetails = details;
        _isCalculatingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = GermanaColors.of(context);
    final cars = _getCars(state);

    return Scaffold(
      backgroundColor: colors.backgroundElevated,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.background,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const Spacer(),
                  Text(l10n.listRideScreenTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: _listed ? _buildSuccess(context) : _buildForm(context, cars),
            ),
            if (!_listed)
              _buildBottomActions(context, cars),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<Map<String, dynamic>> cars) {
    final validationMessage = _submitAttempted ? _validateDraft(cars) : null;
    final journeyReady = _validateJourneyStep() == null;
    final vehicleReady = _validateVehicleStep(cars) == null;

    Widget stepContent() {
      switch (_activeStep) {
        case 0:
          return _buildJourneyStep(context, cars);
        case 1:
          return _buildVehicleAndPricingStep(context, cars);
        case 2:
        default:
          return _buildReviewStep(context, cars);
      }
    }

    final colors = GermanaColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepNavigator(context, cars, journeyReady: journeyReady, vehicleReady: vehicleReady),
        Divider(height: 1, color: colors.divider),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (validationMessage != null) ...[
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 18, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            validationMessage,
                            style: const TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: KeyedSubtree(
                    key: ValueKey(_activeStep),
                    child: stepContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepNavigator(
    BuildContext context,
    List<Map<String, dynamic>> cars, {
    required bool journeyReady,
    required bool vehicleReady,
  }) {
    final colors = GermanaColors.of(context);
    final progress = (_activeStep + 1) / 3;

    return Container(
      color: colors.backgroundElevated,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_activeStep + 1} of 3',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.accentBlue),
              ),
              Text(
                _activeStep == 2
                    ? 'Ready to publish'
                    : _activeStep == 1
                        ? 'Vehicle and pricing'
                        : 'Build your route',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyStep(BuildContext context, List<Map<String, dynamic>> cars) {
    final l10n = AppLocalizations.of(context);
    final colors = GermanaColors.of(context);
    final dateFmt = DateFormat('EEE, d MMM · h:mm a');
    final appState = AppStateProvider.of(context);

    return Column(
      children: [
        _sectionCard(
          context,
          title: 'Journey',
          subtitle: 'Choose start, destination, and departure time.',
          icon: Icons.route_rounded,
          child: Column(
            children: [
              _selectorRow(
                context,
                title: 'From',
                value: _origin?.name ?? l10n.fromFieldHint,
                icon: Icons.trip_origin_rounded,
                onTap: () => _pickOrigin(l10n),
              ),
              const SizedBox(height: 10),
              _selectorRow(
                context,
                title: 'Destination',
                value: _destination?.name ?? l10n.toFieldHint,
                icon: Icons.location_on_outlined,
                onTap: () => _pickDestination(l10n),
              ),
              const SizedBox(height: 10),
              _selectorRow(
                context,
                title: 'Departure',
                value: dateFmt.format(_departure),
                icon: Icons.schedule_rounded,
                onTap: _pickDepartureDateTime,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_isCalculatingRoute)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.straighten_rounded, size: 16, color: AppColors.accentBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _routeDetails == null
                          ? 'Set both points to estimate route distance and time.'
                          : '${_routeDetails!.distanceKm.toStringAsFixed(1)} km · ${_routeDetails!.durationText}',
                      style: AppTextStyles.caption(context).copyWith(color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
              if (_origin != null && _destination != null) ...[
                const SizedBox(height: 12),
                RideMapSnippet(
                  pickupLabel: _origin!.name,
                  destinationLabel: _destination!.name,
                  pickupLat: _origin!.lat,
                  pickupLng: _origin!.lng,
                  destinationLat: _destination!.lat,
                  destinationLng: _destination!.lng,
                  userLat: appState.currentLocationLat,
                  userLng: appState.currentLocationLng,
                  height: 190,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          context,
          title: 'Pickup plan',
          subtitle: 'Control how many pickup points are allowed.',
          icon: Icons.alt_route_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List<Widget>.generate(5, (index) {
                  final selected = _maxPickupPoints == index;
                  return ChoiceChip(
                    label: Text('$index stop${index == 1 ? '' : 's'}'),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _maxPickupPoints = index;
                        if (_pickupPoints.length > index) {
                          _pickupPoints.removeRange(index, _pickupPoints.length);
                        }
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              if (_pickupPoints.isEmpty)
                Text(
                  'No pickup points yet. Add stops passengers can choose from.',
                  style: AppTextStyles.caption(context),
                ),
              ..._pickupPoints.asMap().entries.map((entry) {
                final idx = entry.key;
                final point = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassBox(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 16, color: AppColors.accentBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${idx + 1}. ${point.name}',
                                  style: AppTextStyles.caption(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setState(() => _pickupPoints.removeAt(idx)),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              PillButton(
                label: 'Add pickup point',
                icon: Icons.add_location_alt_outlined,
                isOutlined: true,
                onPressed: _canAddPickup ? _addPickupPoint : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleAndPricingStep(BuildContext context, List<Map<String, dynamic>> cars) {
    final l10n = AppLocalizations.of(context);
    final colors = GermanaColors.of(context);
    final pricing = _pricingFor(cars);

    return Column(
      children: [
        _sectionCard(
          context,
          title: 'Vehicle details',
          subtitle: 'Set the car and plate passengers will see.',
          icon: Icons.directions_car_filled_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: cars.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    final isSelected = index == _selectedCar;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCar = index;
                          if (_useSelectedCarPlate) {
                            _plateController.text = car['plate'] as String;
                          }
                          final cap = _selectedCarSeatCap(cars);
                          if (_seatCount > cap) {
                            _seatCount = cap;
                          }
                        });
                      },
                      child: GlassBox(
                        blur: 16,
                        opacity: isSelected ? 0.55 : 0.25,
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car['name'] as String,
                              style: AppTextStyles.captionBold(context).copyWith(
                                color: isSelected ? AppColors.accentBlue : colors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(car['fuel'] as double).toStringAsFixed(1)} L/100km · ${car['plate']}',
                              style: AppTextStyles.caption(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text('Use custom car name', style: AppTextStyles.captionBold(context)),
                value: _useCustomCarName,
                onChanged: (v) => setState(() => _useCustomCarName = v),
              ),
              if (_useCustomCarName)
                GlassTextField(
                  controller: _customCarController,
                  hint: 'e.g. Proton Persona 2023',
                  prefixIcon: Icons.badge_outlined,
                ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text('Use selected car plate', style: AppTextStyles.captionBold(context)),
                value: _useSelectedCarPlate,
                onChanged: (v) {
                  setState(() {
                    _useSelectedCarPlate = v;
                    if (v) {
                      _plateController.text = cars[_selectedCar]['plate'] as String;
                    }
                  });
                },
              ),
              GlassTextField(
                controller: _plateController,
                hint: l10n.plateHintExample,
                prefixIcon: Icons.pin_outlined,
                readOnly: _useSelectedCarPlate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          context,
          title: 'Capacity and fair pricing',
          subtitle: 'Malaysia fuel tracked + realistic operating costs with safe margin.',
          icon: Icons.calculate_outlined,
          child: Column(
            children: [
              Row(
                children: [
                  Text('Seats available', style: AppTextStyles.captionBold(context)),
                  const Spacer(),
                  IconButton(
                    onPressed: _seatCount > 1 ? () => setState(() => _seatCount--) : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Text('$_seatCount', style: AppTextStyles.headline(context)),
                  IconButton(
                    onPressed: _seatCount < 6
                        ? () {
                            final cap = _selectedCarSeatCap(cars);
                            if (_seatCount < cap) {
                              setState(() => _seatCount++);
                            }
                          }
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Vehicle seat cap: ${_selectedCarSeatCap(cars)} passengers',
                  style: AppTextStyles.caption(context).copyWith(color: colors.textSecondary),
                ),
              ),
              const SizedBox(height: 8),
              _calcRow(context, 'Fuel tracker', _fuelPriceLabel(cars)),
              const SizedBox(height: 6),
              _calcRow(context, l10n.fuelContributionRon, 'RM ${(pricing?.fuelRm ?? 0).toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _calcRow(context, l10n.tollShareLabel, 'RM ${(pricing?.tollRm ?? 0).toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _calcRow(context, 'Maintenance + wear', 'RM ${(pricing?.maintenanceRm ?? 0).toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _calcRow(context, 'Pickup/parking misc', 'RM ${(pricing?.incidentalsRm ?? 0).toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _calcRow(context, 'Driver safety margin (6%)', 'RM ${(pricing?.driverSafetyMarginRm ?? 0).toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _calcRow(context, l10n.seatsLabel, '$_seatCount'),
              Divider(height: 20, color: colors.divider),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recommendedPerSeatLabel,
                    style: AppTextStyles.headline(context).copyWith(fontSize: 15),
                  ),
                  Text(
                    'RM ${_perSeat(cars).toStringAsFixed(2)}',
                    style: AppTextStyles.price(context).copyWith(color: AppColors.accentBlue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (pricing != null) ...[
                GlassTextField(
                  controller: _customFareController,
                  hint: 'Set fare per passenger (RM)',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final customFare = double.tryParse(_customFareController.text.trim()) ?? 0.0;
                    final cap = pricing.perSeatRecommendedRm * 1.15;
                    final isOverCap = customFare > cap;
                    if (isOverCap) {
                      return GlassBox(
                        padding: const EdgeInsets.all(12),
                        tint: Colors.orange,
                        opacity: 0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Fare exceeds +15% guardrail',
                                    style: AppTextStyles.captionBold(context).copyWith(color: Colors.orange),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please provide a reason to justify this higher fare (e.g., luxury vehicle, special detour).',
                              style: AppTextStyles.caption(context),
                            ),
                            const SizedBox(height: 8),
                            GlassTextField(
                              controller: _reasonController,
                              hint: 'Reason for higher fare...',
                              maxLines: 2,
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                ),
                const SizedBox(height: 8),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  pricing == null
                      ? 'Set route to generate realistic fare range.'
                      : 'Suggest tracking base rate +15% max for fair pool.',
                  style: AppTextStyles.caption(context).copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(BuildContext context, List<Map<String, dynamic>> cars) {
    final pricing = _pricingFor(cars);

    return Column(
      children: [
        _sectionCard(
          context,
          title: 'Publish preview',
          subtitle: 'Double-check what passengers will see.',
          icon: Icons.visibility_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _calcRow(context, 'Route', '${_origin?.name ?? '-'} -> ${_destination?.name ?? '-'}'),
              const SizedBox(height: 6),
              _calcRow(context, 'Pickup points', '${_pickupPoints.length} / $_maxPickupPoints configured'),
              const SizedBox(height: 6),
              _calcRow(context, 'Vehicle', _activeCarName(cars)),
              const SizedBox(height: 6),
              _calcRow(
                context,
                'Plate',
                _plateController.text.trim().isEmpty ? '-' : _plateController.text.trim(),
              ),
              const SizedBox(height: 6),
              _calcRow(context, 'Seats', '$_seatCount'),
              const SizedBox(height: 6),
              _calcRow(
                context,
                'Fare per passenger',
                pricing == null ? 'Set route first' : 'RM ${_customFareController.text.trim()}',
              ),
              if (pricing != null && (double.tryParse(_customFareController.text.trim()) ?? 0.0) > pricing.perSeatRecommendedRm * 1.15) ...[
                const SizedBox(height: 6),
                _calcRow(
                  context,
                  'High fare reason',
                  _reasonController.text.trim(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, List<Map<String, dynamic>> cars) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: [
          if (_activeStep > 0)
            Expanded(
              child: PillButton(
                label: 'Back',
                icon: Icons.arrow_back_rounded,
                isOutlined: true,
                onPressed: _goPreviousStep,
              ),
            ),
          if (_activeStep > 0) const SizedBox(width: 10),
          Expanded(
            flex: _activeStep == 0 ? 1 : 2,
            child: PillButton(
              label: _activeStep == 2 ? 'Publish ride' : 'Continue',
              icon: _activeStep == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
              expand: true,
              onPressed: () {
                if (_activeStep == 2) {
                  _onPublish(cars);
                } else {
                  _goNextStep(cars);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final colors = GermanaColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        border: Border(bottom: BorderSide(color: colors.divider ?? Colors.transparent)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AppColors.accentBlue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _selectorRow(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = GermanaColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.divider ?? Colors.transparent, width: 0.8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.accentBlue),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGreen.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 40,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text('Ride published', style: AppTextStyles.title(context)),
          const SizedBox(height: 8),
          Text(
            'Passengers can now discover your listing with your selected pickup settings.',
            style: AppTextStyles.bodySecondary(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PillButton(
            label: 'Back',
            isOutlined: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _calcRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.captionBold(context),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
