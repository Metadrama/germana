import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/screens/driver/driver_hub_screen.dart';
import 'package:germana/screens/driver/list_ride_screen.dart';
import 'package:germana/screens/explore/explore_screen.dart';
import 'package:germana/screens/ledger/ledger_screen.dart';
import 'package:germana/screens/profile/profile_screen.dart';

/// Persistent shell with floating frosted pill navigation bar.
/// Adaptive glass colors for dark/light mode.
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
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'Dashboard',
          ),
          _NavItem(
            icon: Icons.add_circle_outline_rounded,
            activeIcon: Icons.add_circle_rounded,
            label: 'List',
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
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
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: l10n.navRides,
        ),
        _NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          label: l10n.navHistory,
        ),
        _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 84 + MediaQuery.paddingOf(context).bottom,
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildNavBar(context, config.navItems),
          ),
        ],
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

  Widget _buildNavBar(BuildContext context, List<_NavItem> navItems) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = GermanaColors.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(32, 0, 32, bottomPadding + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              color: colors.navSurface,
              border: Border.all(
                color: colors.navBorder,
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isActive = index == _currentIndex;

                return GestureDetector(
                  key: _navItemKeys[index],
                  onTap: () => setState(() => _currentIndex = index),
                  onLongPress: index == 2
                      ? () => _showProfileQuickSwitcher(context)
                      : null,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            key: ValueKey(isActive),
                            size: 22,
                            color: isActive
                                ? AppColors.accentBlue
                                : colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? AppColors.accentBlue
                                : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
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
    final pointerLeft = (anchorX - 10).clamp(18.0, width - 30.0);

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
