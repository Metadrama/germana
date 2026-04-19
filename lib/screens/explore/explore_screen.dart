import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/data/mock_rides_peninsular.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/widgets/glass_text_field.dart';
import 'package:germana/widgets/ride_card.dart';
import 'package:germana/widgets/section_label.dart';
import 'package:germana/screens/explore/ride_detail_screen.dart';
import 'package:germana/screens/explore/places_search_screen.dart';
import 'package:germana/services/location_service.dart';
import 'package:germana/services/ride_discovery_service.dart';
import 'package:intl/intl.dart';

/// Main discovery feed — AFA-inspired card layout.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedFilter = 'all';
  PlaceDetails? _searchDestination;

  String _coordsLabel(double lat, double lng) {
    final latH = lat >= 0 ? 'N' : 'S';
    final lngH = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}°$latH, ${lng.abs().toStringAsFixed(4)}°$lngH';
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final state = AppStateProvider.of(context);
    final l10n = AppLocalizations.of(context);
    final discovery = RideDiscoveryService.discover(
      rides: mockRidesPeninsular,
      selectedFilter: _selectedFilter,
      currentLocationLat: state.currentLocationLat,
      currentLocationLng: state.currentLocationLng,
      selectedLocation: _searchDestination,
    );
    final feedRides = discovery.rides;
    final hasSearchContext = _searchDestination != null;
    final now = DateTime.now();
    final greeting = l10n.greetingForHour(now.hour);
    final dateStr = DateFormat('EEE d MMM', l10n.languageCode).format(now);
    final filters = [
      (id: 'all', label: l10n.allFilter),
      (id: 'now', label: l10n.nowFilter),
      (id: 'scheduled', label: l10n.scheduledFilter),
      (id: 'under5', label: l10n.underFiveFilter),
      (id: 'seats3', label: l10n.threePlusSeatsFilter),
    ];

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Real location header
                  Row(
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        size: 18,
                        color: AppColors.accentBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.currentLocationLabel,
                          style: AppTextStyles.title(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$greeting, ${state.name.split(' ').first} · $dateStr · ${_coordsLabel(state.currentLocationLat, state.currentLocationLng)}',
                    style: AppTextStyles.bodySecondary(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 20),

                  // Location
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.of(context).push<PlaceDetails>(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => PlacesSearchScreen(
                            hint: 'Set current area',
                            initialValue: state.currentLocationLabel,
                          ),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );

                      if (result != null) {
                        state.setCurrentLocation(
                          label: result.name,
                          lat: result.lat,
                          lng: result.lng,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.isDark
                            ? colors.backgroundElevated.withValues(alpha: 0.72)
                            : colors.glassSurface,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                        border: Border.all(color: colors.glassBorderSubtle, width: 0.9),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.my_location_rounded,
                            size: 16,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              state.currentLocationLabel,
                              style: AppTextStyles.captionBold(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'Manual',
                            style: AppTextStyles.caption(context).copyWith(
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search bar
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.of(context).push<PlaceDetails>(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => PlacesSearchScreen(
                            hint: l10n.searchHint,
                            initialValue: _searchDestination?.name,
                          ),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                        ),
                      );
                      if (result != null) setState(() => _searchDestination = result);
                    },
                    child: AbsorbPointer(
                      child: GlassTextField(
                        hint: l10n.searchHint,
                        prefixIcon: Icons.search_rounded,
                        controller: TextEditingController(text: _searchDestination?.name),
                        readOnly: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Filter chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isSelected = filter.id == _selectedFilter;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentBlue
                                  : (colors.isDark
                                      ? colors.backgroundElevated.withValues(alpha: 0.66)
                                      : colors.glassSurface),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentBlue
                                    : colors.glassBorderSubtle,
                                width: 0.9,
                              ),
                            ),
                            child: Text(
                              filter.label,
                              style: AppTextStyles.caption(context).copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  const SizedBox(height: 8),

                  SectionLabel(
                    label: hasSearchContext
                        ? 'Rides to ${_searchDestination!.name}'
                        : l10n.availableRides,
                    trailing: '${feedRides.length} found',
                  ),
                  if (hasSearchContext)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        discovery.appliedRadiusKm != null
                            ? 'From around ${state.currentLocationLabel} • destination within ~${discovery.appliedRadiusKm!.toStringAsFixed(0)} km'
                            : 'From around ${state.currentLocationLabel}',
                        style: AppTextStyles.caption(context),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Ride cards feed with staggered animation
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = feedRides[index];
                  final ride = item.ride;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 80)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: RideCard(
                      ride: ride,
                      distanceFromSearchKm: item.distanceFromSearchKm,
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 320),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 260),
                            pageBuilder: (_, __, ___) =>
                                RideDetailScreen(ride: ride),
                            transitionsBuilder: (_, animation, secondaryAnimation, child) {
                              final primaryCurve = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                                reverseCurve: Curves.easeInCubic,
                              );
                              final slideIn = Tween<Offset>(
                                begin: const Offset(0.07, 0.0),
                                end: Offset.zero,
                              ).animate(primaryCurve);
                              final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(primaryCurve);

                              final slideOut = Tween<Offset>(
                                begin: Offset.zero,
                                end: const Offset(-0.03, 0.0),
                              ).animate(
                                CurvedAnimation(
                                  parent: secondaryAnimation,
                                  curve: Curves.easeOutCubic,
                                ),
                              );

                              return SlideTransition(
                                position: slideOut,
                                child: FadeTransition(
                                  opacity: fadeIn,
                                  child: SlideTransition(
                                    position: slideIn,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: feedRides.length,
              ),
            ),
          ),

          if (feedRides.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: GlassTextField(
                  hint: hasSearchContext
                      ? 'No matching routes from your current area to that destination yet.'
                      : 'No rides match current filters.',
                  readOnly: true,
                  prefixIcon: Icons.info_outline_rounded,
                ),
              ),
            ),

          // Bottom padding for floating nav
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }
}
