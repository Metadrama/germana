import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/widgets/glass_text_field.dart';
import 'package:germana/widgets/pill_button.dart';

/// Quick onboarding profile completion.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  PersonSex _sex = PersonSex.male;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _complete() {
    final state = AppStateProvider.of(context);
    state.updateProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      sex: _sex,
    );
    state.setProfileComplete(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final l10n = AppLocalizations.of(context);

    if (_nameCtrl.text.isEmpty) {
      _nameCtrl.text = state.name;
      _phoneCtrl.text = state.phone;
      _sex = state.sex;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          children: [
            Text(l10n.onboardingTitle, style: AppTextStyles.display(context)),
            const SizedBox(height: 8),
            Text(l10n.onboardingSubtitle, style: AppTextStyles.bodySecondary(context)),
            const SizedBox(height: 24),
            Text(l10n.nameLabel, style: AppTextStyles.caption(context)),
            const SizedBox(height: 8),
            GlassTextField(
              hint: l10n.nameHint,
              controller: _nameCtrl,
            ),
            const SizedBox(height: 16),
            Text(l10n.phoneLabel, style: AppTextStyles.caption(context)),
            const SizedBox(height: 8),
            GlassTextField(
              hint: l10n.phoneHint,
              controller: _phoneCtrl,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            Text(l10n.genderLabel, style: AppTextStyles.caption(context)),
            const SizedBox(height: 8),
            SegmentedButton<PersonSex>(
              segments: [
                ButtonSegment<PersonSex>(
                  value: PersonSex.male,
                  label: Text(l10n.maleButton),
                  icon: Icon(Icons.male_rounded),
                ),
                ButtonSegment<PersonSex>(
                  value: PersonSex.female,
                  label: Text(l10n.femaleButton),
                  icon: Icon(Icons.female_rounded),
                ),
              ],
              selected: <PersonSex>{_sex},
              onSelectionChanged: (selection) {
                setState(() => _sex = selection.first);
              },
            ),
            const SizedBox(height: 28),
            PillButton(
              label: l10n.enterHome,
              icon: Icons.check_rounded,
              expand: true,
              onPressed: _complete,
            ),
          ],
        ),
      ),
    );
  }
}
