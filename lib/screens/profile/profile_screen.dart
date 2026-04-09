import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/widgets/pill_button.dart';
import 'package:germana/widgets/section_label.dart';
import 'package:germana/screens/driver/list_ride_screen.dart';
import 'package:germana/screens/profile/edit_profile_screen.dart';
import 'package:germana/screens/profile/vehicle_chooser_screen.dart';

/// Profile tab — reads from AppState, supports editing and dark mode toggle.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final colors = GermanaColors.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profil', style: AppTextStyles.display(context)),
              // Edit button
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: colors.glassSurface,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Avatar + name
          Center(
            child: Column(
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.glassBorder,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentBlue.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(
                        state.initials,
                        style: AppTextStyles.display(context).copyWith(
                          color: AppColors.accentBlue,
                          fontSize: 36,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(state.name, style: AppTextStyles.title(context)),
                const SizedBox(height: 4),
                Text(state.email,
                    style: AppTextStyles.caption(context)),
                const SizedBox(height: 6),

                // Faculty badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: AppColors.accentBlue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_rounded,
                          size: 14, color: AppColors.accentBlue),
                      const SizedBox(width: 4),
                      Text(
                        state.faculty,
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Stats row
          GlassBox(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(
                  value: '${state.totalRides}',
                  label: 'Perjalanan',
                  context: context,
                ),
                Container(width: 1, height: 32,
                    color: colors.glassBorder),
                _StatColumn(
                  value: '${state.rating}★',
                  label: 'Penilaian',
                  context: context,
                ),
                Container(width: 1, height: 32,
                    color: colors.glassBorder),
                _StatColumn(
                  value: '${state.ridesAsDriver}',
                  label: 'Pemandu',
                  context: context,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Car profile
          const SectionLabel(label: 'Kereta anda'),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VehicleChooserScreen(),
                ),
              );
            },
            child: GlassBox(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: colors.textPrimary.withValues(alpha: 0.05),
                    ),
                    child: Icon(Icons.directions_car_rounded,
                        size: 24, color: colors.textSecondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.carModel,
                            style: AppTextStyles.headline(context)),
                        const SizedBox(height: 2),
                        Text(
                          '${state.carPlate} · ${state.carColor}',
                          style: AppTextStyles.caption(context),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: colors.textTertiary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // List a Ride CTA
          PillButton(
            label: 'Senarai Perjalanan',
            icon: Icons.add_rounded,
            expand: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ListRideScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Settings
          const SectionLabel(label: 'Tetapan'),
          GlassBox(
            opacity: 0.35,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                // Dark mode toggle
                _ThemeToggleRow(),
                Divider(height: 1, color: colors.divider),
                _SettingsRow(
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                ),
                Divider(height: 1, color: colors.divider),
                _SettingsRow(
                  icon: Icons.shield_outlined,
                  label: 'Privasi & Keselamatan',
                ),
                Divider(height: 1, color: colors.divider),
                _SettingsRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Bantuan & Sokongan',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final BuildContext context;
  const _StatColumn({
    required this.value,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.title(context)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }
}

/// Dark mode toggle row.
class _ThemeToggleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final colors = GermanaColors.of(context);

    return ListTile(
      leading: Icon(
        colors.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        size: 20,
        color: colors.textSecondary,
      ),
      title: Text('Mod Gelap',
          style: AppTextStyles.body(context).copyWith(fontSize: 15)),
      trailing: Switch.adaptive(
        value: state.themeMode == ThemeMode.dark ||
            (state.themeMode == ThemeMode.system && colors.isDark),
        activeTrackColor: AppColors.accentBlue,
        onChanged: (val) {
          state.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
        },
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SettingsRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    return ListTile(
      leading: Icon(icon, size: 20, color: colors.textSecondary),
      title: Text(label,
          style: AppTextStyles.body(context).copyWith(fontSize: 15)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: colors.textTertiary, size: 20),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
