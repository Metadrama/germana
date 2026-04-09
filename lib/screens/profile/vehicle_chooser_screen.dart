import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/data/car_database.dart';

import 'package:germana/widgets/pill_button.dart';

/// Vehicle chooser — brand carousel → model grid → plate/color input.
class VehicleChooserScreen extends StatefulWidget {
  const VehicleChooserScreen({super.key});

  @override
  State<VehicleChooserScreen> createState() => _VehicleChooserScreenState();
}

class _VehicleChooserScreenState extends State<VehicleChooserScreen> {
  String _selectedBrand = 'Perodua';
  CarModel? _selectedModel;
  late TextEditingController _plateCtrl;
  String _selectedColor = 'Putih';
  String _searchQuery = '';

  final _colors = [
    'Putih', 'Hitam', 'Perak', 'Kelabu', 'Merah',
    'Biru', 'Coklat', 'Emas', 'Hijau', 'Oren',
  ];

  @override
  void initState() {
    super.initState();
    _plateCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateProvider.of(context);
    if (_plateCtrl.text.isEmpty && _selectedModel == null) {
      _plateCtrl.text = state.carPlate;
      _selectedColor = state.carColor;
      // Try to find current car in database
      final match = malaysiaCarDatabase.where(
        (c) => c.displayName.toLowerCase() == state.carModel.toLowerCase(),
      );
      if (match.isNotEmpty) {
        _selectedModel = match.first;
        _selectedBrand = match.first.brand;
      }
    }
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    super.dispose();
  }

  List<CarModel> get _filteredModels {
    if (_searchQuery.isNotEmpty) {
      return searchCars(_searchQuery);
    }
    return getModelsForBrand(_selectedBrand);
  }

  void _save() {
    if (_selectedModel == null) return;
    final state = AppStateProvider.of(context);
    state.updateCar(
      model: _selectedModel!.displayName,
      plate: _plateCtrl.text.trim().toUpperCase(),
      color: _selectedColor,
      fuelConsumption: _selectedModel!.fuelConsumption,
    );
    Navigator.of(context).pop();
  }

  IconData _bodyTypeIcon(BodyType type) {
    switch (type) {
      case BodyType.sedan:
        return Icons.directions_car_rounded;
      case BodyType.hatchback:
        return Icons.directions_car_filled_rounded;
      case BodyType.suv:
        return Icons.directions_car_rounded;
      case BodyType.mpv:
        return Icons.airport_shuttle_rounded;
      case BodyType.pickup:
        return Icons.local_shipping_rounded;
    }
  }

  String _bodyTypeLabel(BodyType type) {
    switch (type) {
      case BodyType.sedan:
        return 'Sedan';
      case BodyType.hatchback:
        return 'Hatchback';
      case BodyType.suv:
        return 'SUV';
      case BodyType.mpv:
        return 'MPV';
      case BodyType.pickup:
        return 'Pickup';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final models = _filteredModels;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  Text('Pilih Kereta', style: AppTextStyles.headline(context)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Search bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: _SearchBar(
                        onChanged: (q) => setState(() {
                          _searchQuery = q;
                        }),
                      ),
                    ),
                  ),

                  // Brand carousel (hidden during search)
                  if (_searchQuery.isEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: malaysiaBrands.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final brand = malaysiaBrands[index];
                            final isActive = brand == _selectedBrand;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedBrand = brand;
                                // Don't clear selection if same brand
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.accentBlue
                                      : colors.glassSurface,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.accentBlue
                                        : colors.glassBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    brand,
                                    style: AppTextStyles.caption(context).copyWith(
                                      color: isActive
                                          ? Colors.white
                                          : colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Model count
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? '${models.length} model dijumpai'
                            : '${models.length} model',
                        style: AppTextStyles.caption(context),
                      ),
                    ),
                  ),

                  // Model list
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final car = models[index];
                          final isSelected = _selectedModel?.displayName ==
                              car.displayName;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedModel = car),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: GlassBox(
                                blur: 16,
                                opacity: isSelected ? 0.55 : 0.25,
                                borderRadius: 16,
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    // Body type icon
                                    Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: isSelected
                                            ? AppColors.accentBlue
                                                .withValues(alpha: 0.12)
                                            : colors.textTertiary
                                                .withValues(alpha: 0.08),
                                      ),
                                      child: Icon(
                                        _bodyTypeIcon(car.bodyType),
                                        size: 22,
                                        color: isSelected
                                            ? AppColors.accentBlue
                                            : colors.textTertiary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Name + meta
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _searchQuery.isNotEmpty
                                                ? car.displayName
                                                : car.model,
                                            style:
                                                AppTextStyles.headline(context)
                                                    .copyWith(fontSize: 15),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(
                                                _bodyTypeLabel(car.bodyType),
                                                style: AppTextStyles.caption(
                                                    context),
                                              ),
                                              if (car.engineCC != null) ...[
                                                Text(' · ',
                                                    style:
                                                        AppTextStyles.caption(
                                                            context)),
                                                Text(car.engineCC!,
                                                    style:
                                                        AppTextStyles.caption(
                                                            context)),
                                              ],
                                              if (!car.isCurrentlyOnSale) ...[
                                                Text(' · ',
                                                    style:
                                                        AppTextStyles.caption(
                                                            context)),
                                                Text(
                                                  'Dihentikan',
                                                  style: AppTextStyles.caption(
                                                          context)
                                                      .copyWith(
                                                    color:
                                                        AppColors.accentAmber,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Fuel + seats
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          car.fuelLabel,
                                          style: AppTextStyles.captionBold(
                                                  context)
                                              .copyWith(
                                            color: isSelected
                                                ? AppColors.accentBlue
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          car.seatLabel,
                                          style:
                                              AppTextStyles.caption(context),
                                        ),
                                      ],
                                    ),

                                    // Selection indicator
                                    if (isSelected) ...[
                                      const SizedBox(width: 10),
                                      const Icon(Icons.check_circle_rounded,
                                          size: 20,
                                          color: AppColors.accentBlue),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: models.length,
                      ),
                    ),
                  ),

                  // Plate + color (shown when model selected)
                  if (_selectedModel != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlassBox(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Selected car summary
                                  Row(
                                    children: [
                                      Icon(_bodyTypeIcon(
                                              _selectedModel!.bodyType),
                                          size: 20,
                                          color: AppColors.accentBlue),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedModel!.displayName,
                                        style: AppTextStyles.headline(context),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_selectedModel!.fuelLabel} · ${_selectedModel!.seatLabel} · ${_selectedModel!.engineCC ?? ""}',
                                    style: AppTextStyles.caption(context),
                                  ),

                                  Divider(height: 24, color: colors.divider),

                                  // Plate number
                                  Text('No. Pendaftaran',
                                      style: AppTextStyles.caption(context)),
                                  const SizedBox(height: 8),
                                  _PlateInput(controller: _plateCtrl),

                                  const SizedBox(height: 16),

                                  // Color
                                  Text('Warna',
                                      style: AppTextStyles.caption(context)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _colors.map((color) {
                                      final isActive =
                                          color == _selectedColor;
                                      return GestureDetector(
                                        onTap: () => setState(
                                            () => _selectedColor = color),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.accentBlue
                                                : colors.glassSurface,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    AppRadius.pill),
                                            border: Border.all(
                                              color: isActive
                                                  ? AppColors.accentBlue
                                                  : colors.glassBorder,
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            color,
                                            style: AppTextStyles.caption(
                                                    context)
                                                .copyWith(
                                              color: isActive
                                                  ? Colors.white
                                                  : colors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Bottom space
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),

            // Save CTA
            if (_selectedModel != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: PillButton(
                  label: 'Simpan Kereta',
                  icon: Icons.check_rounded,
                  expand: true,
                  onPressed: _save,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Search bar with glass backdrop — filters across all brands.
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: colors.glassSurface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: colors.glassBorder, width: 1),
          ),
          child: TextField(
            onChanged: onChanged,
            style: AppTextStyles.body(context),
            decoration: InputDecoration(
              hintText: 'Cari kereta...',
              hintStyle: AppTextStyles.bodySecondary(context),
              prefixIcon: Icon(Icons.search_rounded,
                  color: colors.textSecondary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}

/// Malaysian-style plate number input (uppercase, formatted).
class _PlateInput extends StatelessWidget {
  final TextEditingController controller;
  const _PlateInput({required this.controller});

  @override
  Widget build(BuildContext context) {

    return GlassBox(
      borderRadius: AppRadius.chip,
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.characters,
        style: AppTextStyles.headline(context).copyWith(
          letterSpacing: 2.0,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          hintText: 'cth. WXY 1234',
          hintStyle: AppTextStyles.bodySecondary(context).copyWith(
            letterSpacing: 2.0,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
