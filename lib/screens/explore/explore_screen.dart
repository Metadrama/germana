import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/data/mock_rides.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/widgets/glass_text_field.dart';
import 'package:germana/widgets/ride_card.dart';
import 'package:germana/widgets/section_label.dart';
import 'package:germana/screens/explore/ride_detail_screen.dart';
import 'package:germana/screens/explore/places_search_screen.dart';
import 'package:germana/services/location_service.dart';
import 'package:intl/intl.dart';

/// Main discovery feed — AFA-inspired card layout.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedFilter = 'Semua';
  final _filters = ['Semua', 'Sekarang', 'Dijadual', '< RM5', '3+ Tempat'];
  
  PlaceDetails? _searchDestination;

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final state = AppStateProvider.of(context);
    final topDestinations = mockRides.take(5).toList();
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Selamat pagi'
        : now.hour < 17
            ? 'Selamat petang'
            : 'Selamat malam';
    final dateStr = DateFormat('EEE d MMM').format(now);

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
                  // Wordmark + greeting
                  Text('germana', style: AppTextStyles.wordmark(context)),
                  const SizedBox(height: 4),
                  Text(
                    '$greeting, ${state.name.split(' ').first} · $dateStr',
                    style: AppTextStyles.bodySecondary(context),
                  ),

                  const SizedBox(height: 20),

                  // Location
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.glassSurface,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      border: Border.all(color: colors.glassBorder),
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

                  const SizedBox(height: 16),

                  // Search bar
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.of(context).push<PlaceDetails>(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => PlacesSearchScreen(
                            hint: 'Ke mana?',
                            initialValue: _searchDestination?.name,
                          ),
                          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                        ),
                      );
                      if (result != null) setState(() => _searchDestination = result);
                    },
                    child: AbsorbPointer(
                      child: GlassTextField(
                        hint: 'Ke mana?',
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
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = filter == _selectedFilter;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentBlue
                                  : colors.glassSurface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentBlue
                                    : colors.glassBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              filter,
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

                  const SectionLabel(label: 'Destinations'),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: topDestinations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final ride = topDestinations[index];
                        final sex = ride.driverSex == DriverSex.female
                            ? 'Perempuan'
                            : 'Lelaki';

                        return Container(
                          width: 220,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.glassSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.glassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ride.destination,
                                style: AppTextStyles.captionBold(context)
                                    .copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${ride.distanceKm.toStringAsFixed(1)} km · RM ${ride.totalPrice.toStringAsFixed(2)}',
                                style: AppTextStyles.caption(context),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${ride.seatsLeft} seats · ${ride.carModel}',
                                style: AppTextStyles.caption(context),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sex: $sex',
                                style: AppTextStyles.caption(context),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  SectionLabel(
                    label: 'Perjalanan tersedia',
                    trailing: 'Lihat semua',
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
                  final ride = mockRides[index];
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
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration:
                                const Duration(milliseconds: 400),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 350),
                            pageBuilder: (_, __, ___) =>
                                RideDetailScreen(ride: ride),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: mockRides.length,
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
