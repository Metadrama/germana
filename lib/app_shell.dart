import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/screens/driver/driver_hub_screen.dart';
import 'package:germana/screens/driver/list_ride_screen.dart';
import 'package:germana/screens/explore/explore_screen.dart';
import 'package:germana/screens/ledger/ledger_screen.dart';
import 'package:germana/screens/profile/profile_screen.dart';
import 'package:germana/core/liquid_glass/liquid_glass_easy.dart';

/// Persistent shell with floating frosted pill navigation bar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final List<GlobalKey> _navItemKeys = List<GlobalKey>.generate(3, (_) => GlobalKey());

  UserRole _effectiveRole(UserRole role) {
    return role == UserRole.driver ? UserRole.driver : UserRole.passenger;
  }

  _ShellConfig _configForRole(UserRole role, AppLocalizations l10n) {
    if (role == UserRole.driver) {
      return const _ShellConfig(
        screens: [
          DriverHubScreen(),
          ListRideScreen(),
          ProfileScreen(),
        ],
        navItems: [
          _NavItem(
            icon: CupertinoIcons.square_grid_2x2,
            activeIcon: CupertinoIcons.square_grid_2x2_fill,
            label: 'Dashboard',
          ),
          _NavItem(
            icon: CupertinoIcons.add_circled,
            activeIcon: CupertinoIcons.add_circled_solid,
            label: 'List',
          ),
          _NavItem(
            icon: CupertinoIcons.person_crop_circle,
            activeIcon: CupertinoIcons.person_crop_circle_fill,
            label: 'Profile',
          ),
        ],
      );
    }

    return _ShellConfig(
      screens: const [
        ExploreScreen(),
        LedgerScreen(),
        ProfileScreen(),
      ],
      navItems: [
        _NavItem(
          icon: CupertinoIcons.house,
          activeIcon: CupertinoIcons.house_fill,
          label: l10n.navRides,
        ),
        _NavItem(
          icon: CupertinoIcons.clock,
          activeIcon: CupertinoIcons.clock_solid,
          label: l10n.navHistory,
        ),
        _NavItem(
          icon: CupertinoIcons.person_crop_circle,
          activeIcon: CupertinoIcons.person_crop_circle_fill,
          label: l10n.navProfile,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final role = _effectiveRole(state.userRole);
    final l10n = AppLocalizations.of(context);
    final config = _configForRole(role, l10n);
    final activeIndex = _currentIndex.clamp(0, config.screens.length - 1);
    final colors = GermanaColors.of(context); // Define colors here
    final isDark = colors.isDark;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: colors.background, // Fill the scaffold background so it's not transparent black
      body: Stack(
        children: [
          LiquidGlassView(
            useSync: true,
            pixelRatio: 0.0, // 0.0 uses device's native DPR
            refreshRate: LiquidGlassRefreshRate.deviceRefreshRate,
            backgroundWidget: Container(
              color: colors.background, // Prevents transparent black from smearing into the blur
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey(role),
                  child: IndexedStack(
                    index: activeIndex,
                    children: config.screens,
                  ),
                ),
              ),
            ),
            children: [
              _buildNavBarLens(context, config.navItems),
            ],
          ),
          // The Drop Shadow Layer behind the lens, but outside LiquidGlassView to not be refracted
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 16,
            child: Center(
              child: IgnorePointer(
                child: Container(
                  width: 260,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LiquidGlass _buildNavBarLens(BuildContext context, List<_NavItem> navItems) {
    final colors = GermanaColors.of(context);
    final isDark = colors.isDark;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return LiquidGlass(
      height: 64,
      width: 260,
      position: LiquidGlassAlignPosition(
        alignment: Alignment.bottomCenter,
        margin: EdgeInsets.only(bottom: bottomPadding + 16),
      ),
      blur: const LiquidGlassBlur(sigmaX: 18, sigmaY: 18),
      
      color: Colors.transparent,
          
      refractionMode: LiquidGlassRefractionMode.shapeRefraction,
      
      // Softer, smoother bend.
      distortion: 0.10, 
      distortionWidth: 12.0, 
      magnification: 1.0, 
      
      // I am completely turning off chromatic aberration. 
      // The yellow/blue ringing around the blurred text is causing the "dirty" look.
      chromaticAberration: 0.0, 
      saturation: 1.25, 
      
      shape: const RoundedRectangleShape(
        cornerRadius: 100,
        borderWidth: 0.0,
        borderSoftness: 0.0,
        lightIntensity: 0.0,
        lightColor: Colors.transparent,
        shadowColor: Colors.transparent, 
        oneSideLightIntensity: 0.0,
      ),
      
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.black.withValues(alpha: 0.35) 
              : Colors.white.withValues(alpha: 0.30), // Slightly more milkiness to hide messy text contrast
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.10),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            final isActive = index == _currentIndex;
            final activeColor = AppColors.accentBlue;
            final inactiveColor = isDark ? Colors.white : const Color(0xFF3C3C43);
            final color = isActive ? activeColor : inactiveColor;

            return GestureDetector(
              key: _navItemKeys[index],
              onTap: () => setState(() => _currentIndex = index),
              onLongPress: index == 2
                  ? () => _showProfileQuickSwitcher(context)
                  : null,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: 52,
                constraints: const BoxConstraints(minWidth: 76),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  // Replaced the dark grey blob in light mode with a luminous white
                  color: isActive
                      ? (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.6))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  // Apple segmented control style shadow for the active item in light mode
                  boxShadow: isActive && !isDark 
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        )
                      ] 
                    : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      size: 24,
                      color: color,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: color,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _showProfileQuickSwitcher(BuildContext context) async {
    final state = AppStateProvider.of(context);
    final key = _navItemKeys[2];
    final itemContext = key.currentContext;
    if (itemContext == null) return;

    final itemBox = itemContext.findRenderObject() as RenderBox;
    final overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox;
    final targetTopLeft = itemBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final targetRect = targetTopLeft & itemBox.size;

    final currentRole = _effectiveRole(state.userRole);
    final popupSelection = await showGeneralDialog<_RoleSwitchAction>(
      context: context,
      barrierLabel: 'Role switcher',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, _) {
        final colors = GermanaColors.of(dialogContext);
        final media = MediaQuery.of(dialogContext).size;
        final cardWidth = (media.width - 24).clamp(248.0, 280.0).toDouble();
        const cardHeight = 196.0;

        final left = (targetRect.center.dx - (cardWidth / 2))
            .clamp(12.0, media.width - cardWidth - 12.0);
        const verticalGap = 4.0;
        final preferredTop = targetRect.top - cardHeight - verticalGap;
        final showBelow = preferredTop < 20;
        final top = showBelow ? targetRect.bottom + verticalGap : preferredTop;

        return Stack(
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) {
                  return Container(
                    color: Colors.black.withValues(alpha: 0.13 * t),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                behavior: HitTestBehavior.opaque,
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: _RoleSwitcherCard(
                colors: colors,
                currentRole: currentRole,
                anchorX: targetRect.center.dx - left,
                width: cardWidth,
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
    );

    if (!mounted || popupSelection == null) return;

    switch (popupSelection) {
      case _RoleSwitchAction.passenger:
        state.setUserRole(UserRole.passenger);
        setState(() => _currentIndex = 0);
        break;
      case _RoleSwitchAction.driver:
        state.setUserRole(UserRole.driver);
        setState(() => _currentIndex = 0);
        break;
    }
  }
}

enum _RoleSwitchAction {
  passenger,
  driver,
}

class _RoleSwitcherCard extends StatelessWidget {
  final GermanaColors colors;
  final UserRole currentRole;
  final double anchorX;
  final double width;

  const _RoleSwitcherCard({
    required this.colors,
    required this.currentRole,
    required this.anchorX,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: width,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              decoration: BoxDecoration(
                color: colors.backgroundElevated.withValues(alpha: 0.98),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.navBorder, width: 0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Switch mode',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _RoleSwitchTile(
                    icon: Icons.person_rounded,
                    title: 'Passenger mode',
                    subtitle: 'Discover and join rides',
                    selected: currentRole != UserRole.driver,
                    onTap: () => Navigator.of(context).pop(_RoleSwitchAction.passenger),
                  ),
                  const SizedBox(height: 8),
                  _RoleSwitchTile(
                    icon: Icons.directions_car_rounded,
                    title: 'Driver mode',
                    subtitle: 'List and manage carpools',
                    selected: currentRole == UserRole.driver,
                    onTap: () => Navigator.of(context).pop(_RoleSwitchAction.driver),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? AppColors.accentBlue.withValues(alpha: 0.16)
              : colors.backgroundElevated.withValues(alpha: 0.22),
          border: Border.all(
            color: selected
                ? AppColors.accentBlue.withValues(alpha: 0.52)
                : colors.glassBorderSubtle,
            width: 0.9,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentBlue.withValues(alpha: 0.14),
              ),
              child: Icon(icon, size: 19, color: AppColors.accentBlue),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: selected ? 1 : 0,
              child: const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.accentBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellConfig {
  final List<Widget> screens;
  final List<_NavItem> navItems;

  const _ShellConfig({required this.screens, required this.navItems});
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
