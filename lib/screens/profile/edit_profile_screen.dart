import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/core/app_state.dart';

import 'package:germana/widgets/pill_button.dart';

/// Edit Profile screen — allows updating name, email, phone, faculty.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  String _selectedFaculty = 'UniKL MIIT';

  final _faculties = [
    'UniKL MIIT',
    'UniKL BMI',
    'UniKL MFI',
    'UniKL MICET',
    'UniKL MIAT',
    'UniKL MSI',
    'UniKL RCMP',
  ];

  @override
  void initState() {
    super.initState();
    // Will be populated in didChangeDependencies
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateProvider.of(context);
    if (_nameCtrl.text.isEmpty) {
      _nameCtrl.text = state.name;
      _emailCtrl.text = state.email;
      _phoneCtrl.text = state.phone;
      _selectedFaculty = state.faculty;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final state = AppStateProvider.of(context);
    state.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      faculty: _selectedFaculty,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.glassSurface,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const Spacer(),
                  Text('Sunting Profil',
                      style: AppTextStyles.headline(context)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama', style: AppTextStyles.caption(context)),
                    const SizedBox(height: 8),
                    _GlassInput(controller: _nameCtrl, hint: 'Nama penuh'),

                    const SizedBox(height: 20),

                    Text('E-mel Institusi',
                        style: AppTextStyles.caption(context)),
                    const SizedBox(height: 8),
                    _GlassInput(
                      controller: _emailCtrl,
                      hint: 'nama@smail.unikl.edu.my',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    Text('No. Telefon',
                        style: AppTextStyles.caption(context)),
                    const SizedBox(height: 8),
                    _GlassInput(
                      controller: _phoneCtrl,
                      hint: '+60 11-XXXX XXXX',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 20),

                    Text('Fakulti', style: AppTextStyles.caption(context)),
                    const SizedBox(height: 8),
                    GlassBox(
                      borderRadius: AppRadius.pill,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      child: DropdownButton<String>(
                        value: _selectedFaculty,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: colors.cardFill,
                        style: AppTextStyles.body(context),
                        items: _faculties
                            .map((f) => DropdownMenuItem(
                                value: f, child: Text(f)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedFaculty = v);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Save CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: PillButton(
                label: 'Simpan',
                icon: Icons.check_rounded,
                expand: true,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal glass input with a TextEditingController.
class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _GlassInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {

    return GlassBox(
      borderRadius: AppRadius.pill,
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.body(context),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySecondary(context),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
