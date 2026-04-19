import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:germana/app_shell.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/screens/auth/onboarding_screen.dart';
import 'package:germana/screens/auth/permissions_screen.dart';
import 'package:germana/screens/auth/sign_in_screen.dart';

/// Top-level app flow gate for auth, permissions, onboarding, and main shell.
class RootFlow extends StatefulWidget {
  const RootFlow({super.key});

  @override
  State<RootFlow> createState() => _RootFlowState();
}

class _RootFlowState extends State<RootFlow> {
  bool _startedHydration = false;
  bool _appliedMockPermissions = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_startedHydration) return;

    _startedHydration = true;
    AppStateProvider.of(context).hydrate();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    if (kIsWeb &&
      state.isHydrated &&
      state.isAuthenticated &&
      state.isProfileComplete &&
      !state.hasRequiredPermissions) {
      if (!_appliedMockPermissions) {
        _appliedMockPermissions = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          state.setPermissions(location: true, notifications: true);
        });
      }

      return const Center(child: CircularProgressIndicator());
    }

    if (!state.isHydrated) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.isAuthenticated) {
      return const SignInScreen();
    }

    if (!state.hasRequiredPermissions) {
      return const PermissionsScreen();
    }

    if (!state.isProfileComplete) {
      return const OnboardingScreen();
    }

    return const AppShell();
  }
}
