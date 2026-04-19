import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.appName, style: AppTextStyles.display(context)),
              const SizedBox(height: 8),
              Text(l10n.signInSubtitle, style: AppTextStyles.bodySecondary(context)),
              const SizedBox(height: 28),
              GlassTextField(
                hint: l10n.signInHint,
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
                label: l10n.signInContinue,
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
                      l10n.signInClosedLoop,
                      style: AppTextStyles.caption(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
