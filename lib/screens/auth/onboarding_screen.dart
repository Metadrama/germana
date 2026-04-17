import 'package:flutter/material.dart';
import 'package:germana/core/app_state.dart';
import 'package:germana/core/theme.dart';
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

    if (_nameCtrl.text.isEmpty) {
      _nameCtrl.text = state.name;
      _phoneCtrl.text = state.phone;
      _sex = state.sex;
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        children: [
          Text('Complete Profile', style: AppTextStyles.display(context)),
          const SizedBox(height: 8),
          Text(
            'Setkan driver info asas sebelum masuk ke Home.',
            style: AppTextStyles.bodySecondary(context),
          ),
          const SizedBox(height: 24),
          Text('Nama', style: AppTextStyles.caption(context)),
          const SizedBox(height: 8),
          GlassTextField(
            hint: 'Nama penuh',
            controller: _nameCtrl,
          ),
          const SizedBox(height: 16),
          Text('Telefon', style: AppTextStyles.caption(context)),
          const SizedBox(height: 8),
          GlassTextField(
            hint: '+60 1X-XXXX XXXX',
            controller: _phoneCtrl,
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: 16),
          Text('Jantina', style: AppTextStyles.caption(context)),
          const SizedBox(height: 8),
          SegmentedButton<PersonSex>(
            segments: const [
              ButtonSegment<PersonSex>(
                value: PersonSex.male,
                label: Text('Lelaki'),
                icon: Icon(Icons.male_rounded),
              ),
              ButtonSegment<PersonSex>(
                value: PersonSex.female,
                label: Text('Perempuan'),
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
            label: 'Enter Home',
            icon: Icons.check_rounded,
            expand: true,
            onPressed: _complete,
          ),
        ],
      ),
    );
  }
}
