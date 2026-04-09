import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/screens/explore/explore_screen.dart';
import 'package:germana/screens/my_rides/my_rides_screen.dart';
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

  final _screens = const [
    ExploreScreen(),
    MyRidesScreen(),
    LedgerScreen(),
    ProfileScreen(),
  ];

  final _navItems = const [
    _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Terokai'),
    _NavItem(icon: Icons.directions_car_outlined, activeIcon: Icons.directions_car_rounded, label: 'Saya'),
    _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Lejar'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildNavBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = GermanaColors.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(32, 0, 32, bottomPadding + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              color: colors.navSurface,
              border: Border.all(
                color: colors.navBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: colors.isDark ? 0.3 : 0.08,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isActive = index == _currentIndex;

                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
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
                                : colors.textTertiary,
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
                                : colors.textTertiary,
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
