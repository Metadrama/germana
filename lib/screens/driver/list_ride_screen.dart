import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/widgets/glass_text_field.dart';
import 'package:germana/widgets/pill_button.dart';
import 'package:germana/screens/explore/places_search_screen.dart';
import 'package:germana/services/location_service.dart';

/// Single condensed screen for listing a ride as a driver.
/// Uses live car data from AppState.
class ListRideScreen extends StatefulWidget {
  const ListRideScreen({super.key});

  @override
  State<ListRideScreen> createState() => _ListRideScreenState();
}

class _ListRideScreenState extends State<ListRideScreen> {
  int _selectedCar = 0;
  bool _listed = false;
  
  PlaceDetails? _origin;
  PlaceDetails? _destination;
  RouteDetails? _routeDetails;
  bool _isCalculatingRoute = false;
  final LocationService _locationService = LocationService();

  // Mock car options (first one is from profile)
  List<Map<String, dynamic>> _getCars(AppState state) => [
    {
      'name': state.carModel,
      'fuel': state.carFuelConsumption,
      'plate': state.carPlate,
    },
    {'name': 'Perodua Axia', 'fuel': 5.8, 'plate': 'ABC 5678'},
    {'name': 'Honda City', 'fuel': 7.0, 'plate': 'DEF 9012'},
  ];

  double _fuelRate(List<Map<String, dynamic>> cars) {
    if (_routeDetails == null) return 0.0;
    // (KM / 100) * L/100km * RM2.05 (RON95)
    return (_routeDetails!.distanceKm / 100) * (cars[_selectedCar]['fuel'] as double) * 2.05;
  }
  
  double get _tollRate => 2.00; // Hardcoded mock toll for now
  
  double _perSeat(List<Map<String, dynamic>> cars) {
    if (_routeDetails == null) return 0.0;
    return double.parse(((_fuelRate(cars) + _tollRate) / 4).toStringAsFixed(2));
  }
  
  Future<void> _calculateRoute() async {
    if (_origin != null && _destination != null) {
      setState(() => _isCalculatingRoute = true);
      final details = await _locationService.getDirections(_origin!, _destination!);
      setState(() {
        _routeDetails = details;
        _isCalculatingRoute = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final state = AppStateProvider.of(context);
    final l10n = AppLocalizations.of(context);
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
                  Text(l10n.listRideScreenTitle,
                      style: AppTextStyles.headline(context)),
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
                  label: l10n.listButton,
                  icon: Icons.check_rounded,
                  expand: true,
                  onPressed: () => setState(() => _listed = true),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<Map<String, dynamic>> cars) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
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
          },
          child: AbsorbPointer(
            child: GlassTextField(
              hint: l10n.fromFieldHint,
              prefixIcon: Icons.trip_origin_rounded,
              controller: TextEditingController(text: _origin?.name),
              readOnly: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
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
          },
          child: AbsorbPointer(
            child: GlassTextField(
              hint: l10n.toFieldHint,
              prefixIcon: Icons.location_on_outlined,
              controller: TextEditingController(text: _destination?.name),
              readOnly: true,
            ),
          ),
        ),

        const SizedBox(height: 28),

        Text(l10n.yourCarLabel, style: AppTextStyles.headline(context)),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cars.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final car = cars[index];
              final isSelected = index == _selectedCar;
              return GestureDetector(
                onTap: () => setState(() => _selectedCar = index),
                child: GlassBox(
                  blur: 16,
                  opacity: isSelected ? 0.55 : 0.25,
                  borderRadius: 16,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car['name'] as String,
                        style: AppTextStyles.captionBold(context).copyWith(
                          color: isSelected
                              ? AppColors.accentBlue
                              : GermanaColors.of(context).textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(car['fuel'] as double).toStringAsFixed(1)} L/100km',
                        style: AppTextStyles.caption(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 28),

        // Fair rate calculation
        GlassBox(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calculate_outlined,
                      size: 18, color: AppColors.accentBlue),
                  const SizedBox(width: 8),
                  Text(l10n.fairRateLabel,
                      style: AppTextStyles.headline(context)),
                  const Spacer(),
                  if (_isCalculatingRoute)
                    const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_routeDetails != null)
                    Text(
                      '${_routeDetails!.distanceKm.toStringAsFixed(1)} KM · ${_routeDetails!.durationText}',
                      style: AppTextStyles.caption(context).copyWith(color: AppColors.accentBlue),
                    )
                ],
              ),
              const SizedBox(height: 14),
              _calcRow(context, l10n.fuelContributionRon,
                  'RM ${_fuelRate(cars).toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _calcRow(context, l10n.tollShareLabel,
                  'RM ${_tollRate.toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _calcRow(context, l10n.seatsLabel, '4'),
              Divider(height: 20,
                  color: GermanaColors.of(context).divider),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.recommendedPerSeatLabel,
                      style: AppTextStyles.headline(context)
                          .copyWith(fontSize: 15)),
                  Text(
                    'RM ${_perSeat(cars).toStringAsFixed(2)}',
                    style: AppTextStyles.price(context)
                        .copyWith(color: AppColors.accentBlue),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${l10n.priceRangeHint} (RM ${(_perSeat(cars) * 1.15).toStringAsFixed(2)})',
                style: AppTextStyles.caption(context).copyWith(
                  color: GermanaColors.of(context).textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGreen.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.check_rounded,
                size: 40, color: AppColors.accentGreen),
          ),
          const SizedBox(height: 20),
          Text(l10n.listedSuccessTitle, style: AppTextStyles.title(context)),
          const SizedBox(height: 8),
          Text(
            l10n.listedSuccessMessage,
            style: AppTextStyles.bodySecondary(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PillButton(
            label: l10n.backLabel,
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
        Text(label, style: AppTextStyles.caption(context)),
        Text(value, style: AppTextStyles.captionBold(context)),
      ],
    );
  }
}
