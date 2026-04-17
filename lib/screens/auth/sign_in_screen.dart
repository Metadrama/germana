import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/widgets/glass_text_field.dart';
import 'package:germana/widgets/pill_button.dart';

/// Institutional email sign-in screen.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    final state = AppStateProvider.of(context);
    final ok = state.signIn(_emailCtrl.text);

    if (!ok) {
      setState(() {
        _error = 'Guna e-mel institusi (@${state.emailDomain})';
      });
      return;
    }

    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GERMANA', style: AppTextStyles.display(context)),
            const SizedBox(height: 8),
            Text(
              'Sign in untuk akses rides, receipts, dan profil pemandu.',
              style: AppTextStyles.bodySecondary(context),
            ),
            const SizedBox(height: 28),
            GlassTextField(
              hint: 'nama@smail.unikl.edu.my',
              prefixIcon: Icons.alternate_email_rounded,
              controller: _emailCtrl,
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: AppTextStyles.caption(context)
                    .copyWith(color: AppColors.accentRed),
              ),
            ],
            const SizedBox(height: 20),
            PillButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              expand: true,
              onPressed: _continue,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.verified_user_rounded,
                    size: 16, color: colors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Closed-loop access for verified campus users only.',
                    style: AppTextStyles.caption(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
