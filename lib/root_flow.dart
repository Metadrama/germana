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
