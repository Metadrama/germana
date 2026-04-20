import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/widgets/section_label.dart';
import 'package:germana/screens/profile/edit_profile_screen.dart';
import 'package:germana/screens/profile/vehicle_chooser_screen.dart';

/// Profile tab — reads from AppState, supports editing and dark mode toggle.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final colors = GermanaColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.navProfile, style: AppTextStyles.display(context)),
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
                Text(
                  state.sex == PersonSex.female ? l10n.femaleLabel : l10n.maleLabel,
                  style: AppTextStyles.captionBold(context),
                ),
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
                  label: l10n.trips,
                  context: context,
                ),
                Container(width: 1, height: 32,
                    color: colors.glassBorder),
                _StatColumn(
                  value: '${state.rating}★',
                  label: l10n.rating,
                  context: context,
                ),
                Container(width: 1, height: 32,
                    color: colors.glassBorder),
                _StatColumn(
                  value: '${state.ridesAsDriver}',
                  label: l10n.driver,
                  context: context,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Settings
          SectionLabel(label: l10n.settings),
          GlassBox(
            opacity: 0.35,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                // Dark mode toggle
                _ThemeToggleRow(),
                Divider(height: 1, color: colors.divider),
                _SettingsRow(
                  icon: Icons.directions_car_filled_rounded,
                  label: l10n.yourCar,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const VehicleChooserScreen(),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: colors.divider),
                _SettingsRow(
                  icon: Icons.notifications_outlined,
                  label: l10n.notifications,
                ),
                Divider(height: 1, color: colors.divider),
                _SettingsRow(
                  icon: Icons.shield_outlined,
                  label: l10n.privacySafety,
                ),
                Divider(height: 1, color: colors.divider),
                _SettingsRow(
                  icon: Icons.help_outline_rounded,
                  label: l10n.helpSupport,
                ),
                Divider(height: 1, color: colors.divider),
                _LanguageSettingsRow(),
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
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: Icon(
        colors.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
        size: 20,
        color: colors.textSecondary,
      ),
        title: Text(l10n.darkMode,
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
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    return ListTile(
      onTap: onTap,
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

class _LanguageSettingsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final l10n = AppLocalizations.of(context);
    final colors = GermanaColors.of(context);

    final options = <Locale, String>{
      const Locale('en'): l10n.languageEnglish,
      const Locale('ms'): l10n.languageMalay,
      const Locale('zh'): l10n.languageChinese,
      const Locale('ta'): l10n.languageTamil,
    };

    final currentLocale = options.keys.firstWhere(
      (locale) => locale.languageCode == state.locale.languageCode,
      orElse: () => const Locale('en'),
    );

    return ListTile(
      leading: Icon(Icons.language_rounded, size: 20, color: colors.textSecondary),
      title: Text(l10n.language,
          style: AppTextStyles.body(context).copyWith(fontSize: 15)),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: Align(
          alignment: Alignment.centerRight,
          child: DropdownButton<Locale>(
            isDense: true,
            value: currentLocale,
            underline: const SizedBox(),
            items: options.entries
                .map(
                  (entry) => DropdownMenuItem<Locale>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (locale) {
              if (locale != null) {
                state.setLocale(locale);
              }
            },
          ),
        ),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
