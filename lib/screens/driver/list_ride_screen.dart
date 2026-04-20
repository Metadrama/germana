import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/screens/explore/places_search_screen.dart';
import 'package:germana/services/fair_rate_service.dart';
import 'package:germana/services/location_service.dart';
import 'package:germana/services/malaysia_fuel_price_service.dart';
import 'package:germana/widgets/glass_text_field.dart';
import 'package:germana/widgets/pill_button.dart';
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
  bool _useSelectedCarPlate = true;
  bool _useCustomCarName = false;

  bool _submitAttempted = false;
  bool _listed = false;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController();
    _customCarController = TextEditingController();
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
    super.dispose();
  }

  List<Map<String, dynamic>> _getCars(AppState state) => [
        {
          'name': state.carModel,
          'fuel': state.carFuelConsumption,
          'plate': state.carPlate,
          'fuelType': FuelType.ron95,
        },
        {
          'name': 'Perodua Axia',
          'fuel': 5.8,
          'plate': 'ABC 5678',
          'fuelType': FuelType.ron95,
        },
        {
          'name': 'Honda City',
          'fuel': 7.0,
          'plate': 'DEF 9012',
          'fuelType': FuelType.ron97,
        },
      ];

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
        pageBuilder: (_, __, ___) => PlacesSearchScreen(
          hint: l10n.fromWhereHint,
          initialValue: _origin?.name,
        ),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
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
        pageBuilder: (_, __, ___) => PlacesSearchScreen(
          hint: l10n.toWhereHint,
          initialValue: _destination?.name,
        ),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
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
        pageBuilder: (_, __, ___) => const PlacesSearchScreen(
          hint: 'Pickup point',
        ),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
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
    );
    state.publishDriverRide(ride);

    setState(() => _listed = true);
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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.glassSurface,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const Spacer(),
                  Text(l10n.listRideScreenTitle, style: AppTextStyles.headline(context)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _listed ? _buildSuccess(context) : _buildForm(context, cars),
              ),
            ),
            if (!_listed)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: PillButton(
                  label: 'Publish ride',
                  icon: Icons.check_rounded,
                  expand: true,
                  onPressed: () => _onPublish(cars),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<Map<String, dynamic>> cars) {
    final l10n = AppLocalizations.of(context);
    final colors = GermanaColors.of(context);
    final dateFmt = DateFormat('EEE, d MMM · h:mm a');
    final validationMessage = _submitAttempted ? _validateDraft(cars) : null;
    final pricing = _pricingFor(cars);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (validationMessage != null) ...[
          GlassBox(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 18, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    validationMessage,
                    style: AppTextStyles.caption(context).copyWith(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

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
                        onPressed: () {
                          setState(() => _pickupPoints.removeAt(idx));
                        },
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

        const SizedBox(height: 16),

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
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                    onPressed: _seatCount > 1
                        ? () => setState(() => _seatCount--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Text('$_seatCount', style: AppTextStyles.headline(context)),
                  IconButton(
                    onPressed: _seatCount < 6
                        ? () => setState(() => _seatCount++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _calcRow(
                context,
                'Fuel tracker',
                _fuelPriceLabel(cars),
              ),
              const SizedBox(height: 6),
              _calcRow(
                context,
                l10n.fuelContributionRon,
                'RM ${(pricing?.fuelRm ?? 0).toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              _calcRow(
                context,
                l10n.tollShareLabel,
                'RM ${(pricing?.tollRm ?? 0).toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              _calcRow(
                context,
                'Maintenance + wear',
                'RM ${(pricing?.maintenanceRm ?? 0).toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              _calcRow(
                context,
                'Pickup/parking misc',
                'RM ${(pricing?.incidentalsRm ?? 0).toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              _calcRow(
                context,
                'Driver safety margin (6%)',
                'RM ${(pricing?.driverSafetyMarginRm ?? 0).toStringAsFixed(2)}',
              ),
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
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  pricing == null
                      ? 'Set route to generate realistic fare range.'
                      : 'Suggested range: RM ${pricing.perSeatLowerRm.toStringAsFixed(2)} - RM ${pricing.perSeatUpperRm.toStringAsFixed(2)} / seat',
                  style: AppTextStyles.caption(context).copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

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
              _calcRow(
                context,
                'Pickup points',
                '${_pickupPoints.length} / $_maxPickupPoints configured',
              ),
              const SizedBox(height: 6),
              _calcRow(context, 'Vehicle', _activeCarName(cars)),
              const SizedBox(height: 6),
              _calcRow(
                context,
                'Plate',
                _plateController.text.trim().isEmpty
                    ? '-'
                    : _plateController.text.trim(),
              ),
              const SizedBox(height: 6),
              _calcRow(context, 'Seats', '$_seatCount'),
              const SizedBox(height: 6),
              _calcRow(
                context,
                'Suggested fare',
                pricing == null
                    ? 'Set route first'
                    : 'RM ${pricing.perSeatRecommendedRm.toStringAsFixed(2)} per seat',
              ),
            ],
          ),
        ),
      ],
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
    return GlassBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.accentBlue),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.headline(context)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption(context).copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 14),
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
      child: GlassBox(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.accentBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.caption(context).copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionBold(context),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
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
