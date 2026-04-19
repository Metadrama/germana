import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/widgets/pill_button.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission education and OS request step.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _location = false;
  bool _notifications = false;
  bool _mockPermissionsApplied = false;

  void _applyMockPermissions() {
    final state = AppStateProvider.of(context);
    setState(() {
      _location = true;
      _notifications = true;
      _mockPermissionsApplied = true;
    });
    state.setPermissions(location: true, notifications: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (kIsWeb && !_mockPermissionsApplied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _mockPermissionsApplied) return;
        _applyMockPermissions();
      });
    }
  }

  Future<void> _requestLocation(bool enabled) async {
    if (!enabled) {
      setState(() => _location = false);
      return;
    }

    if (kIsWeb) {
      setState(() => _location = true);
      return;
    }

    final result = await Permission.locationWhenInUse.request();
    setState(() => _location = result.isGranted);
  }

  Future<void> _requestNotifications(bool enabled) async {
    if (!enabled) {
      setState(() => _notifications = false);
      return;
    }

    if (kIsWeb) {
      setState(() => _notifications = true);
      return;
    }

    final result = await Permission.notification.request();
    setState(() => _notifications = result.isGranted);
  }

  void _continue() {
    final state = AppStateProvider.of(context);
    state.setPermissions(location: _location, notifications: _notifications);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final canMockPermissions = kIsWeb || kDebugMode;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.permissionsTitle, style: AppTextStyles.display(context)),
              const SizedBox(height: 8),
              Text(l10n.permissionsSubtitle, style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 24),
              GlassBox(
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                        title: Text(l10n.locationPermissionTitle,
                          style: AppTextStyles.body(context)
                              .copyWith(fontSize: 15)),
                        subtitle: Text(l10n.locationPermissionSubtitle,
                          style: AppTextStyles.caption(context)),
                      value: _location,
                      onChanged: (v) => _requestLocation(v),
                      activeTrackColor: AppColors.accentBlue,
                    ),
                    const Divider(),
                    SwitchListTile.adaptive(
                      title: Text(l10n.notificationsPermissionTitle,
                          style: AppTextStyles.body(context)
                              .copyWith(fontSize: 15)),
                      subtitle: Text(l10n.notificationsPermissionSubtitle,
                          style: AppTextStyles.caption(context)),
                      value: _notifications,
                      onChanged: (v) => _requestNotifications(v),
                      activeTrackColor: AppColors.accentBlue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.domainActive(state.emailDomain),
                style: AppTextStyles.caption(context),
              ),
              if (canMockPermissions) ...[
                const SizedBox(height: 14),
                GlassBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.browserDebugMockTitle,
                        style: AppTextStyles.body(context).copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.browserDebugMockDescription,
                        style: AppTextStyles.caption(context),
                      ),
                      const SizedBox(height: 12),
                      PillButton(
                        label: _mockPermissionsApplied
                            ? l10n.mockPermissionsEnabled
                            : l10n.enableMockPermissions,
                        icon: Icons.bug_report_rounded,
                        expand: true,
                        onPressed: _mockPermissionsApplied
                            ? null
                            : _applyMockPermissions,
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              PillButton(
                label: l10n.continueLabel,
                icon: Icons.arrow_forward_rounded,
                expand: true,
                onPressed: (_location && _notifications) ? _continue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
