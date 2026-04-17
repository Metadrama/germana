import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
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

  Future<void> _requestLocation(bool enabled) async {
    if (!enabled) {
      setState(() => _location = false);
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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Permissions', style: AppTextStyles.display(context)),
            const SizedBox(height: 8),
            Text(
              'Kami perlukan akses asas untuk ranking rides berdekatan dan notifikasi tempahan.',
              style: AppTextStyles.bodySecondary(context),
            ),
            const SizedBox(height: 24),
            GlassBox(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: Text('Location (while in use)',
                        style: AppTextStyles.body(context)
                            .copyWith(fontSize: 15)),
                    subtitle: Text('Untuk distance (km) & pickup relevance.',
                        style: AppTextStyles.caption(context)),
                    value: _location,
                    onChanged: (v) => _requestLocation(v),
                    activeTrackColor: AppColors.accentBlue,
                  ),
                  const Divider(),
                  SwitchListTile.adaptive(
                    title: Text('Notifications',
                        style: AppTextStyles.body(context)
                            .copyWith(fontSize: 15)),
                    subtitle: Text('Untuk status pembayaran dan designated time reminder.',
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
              'Domain aktif: @${state.emailDomain}',
              style: AppTextStyles.caption(context),
            ),
            const Spacer(),
            PillButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              expand: true,
              onPressed: (_location && _notifications) ? _continue : null,
            ),
          ],
        ),
      ),
    );
  }
}
