import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/widgets/pill_button.dart';
import 'package:germana/screens/explore/booking_confirmed_screen.dart';

/// Payment screen — Touch 'n Go / DuitNow / FPX options (Malaysian market).
class PaymentScreen extends StatefulWidget {
  final RideModel ride;

  const PaymentScreen({super.key, required this.ride});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0;
  bool _processing = false;

  void _confirmPayment() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) =>
            BookingConfirmedScreen(ride: widget.ride),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final l10n = AppLocalizations.of(context);

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
                    onPressed: _processing
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.glassSurface,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const Spacer(),
                  Text(l10n.paymentTitle, style: AppTextStyles.headline(context)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(l10n.amount, style: AppTextStyles.bodySecondary(context)),
                    const SizedBox(height: 8),
                    Text(
                      'RM ${widget.ride.totalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.priceLarge(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.ride.origin} → ${widget.ride.destination}',
                      style: AppTextStyles.caption(context),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 40),

                    Text(l10n.payWith, style: AppTextStyles.headline(context)),
                    const SizedBox(height: 16),

                    // Touch 'n Go eWallet
                    _PaymentMethodCard(
                      label: "Touch 'n Go eWallet",
                      subtitle: l10n.instantPayment,
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: AppColors.tngBlue,
                      isSelected: _selectedMethod == 0,
                      onTap: () => setState(() => _selectedMethod = 0),
                    ),
                    const SizedBox(height: 10),

                    // DuitNow
                    _PaymentMethodCard(
                      label: 'DuitNow QR',
                      subtitle: l10n.instantPayment,
                      icon: Icons.qr_code_rounded,
                      isSelected: _selectedMethod == 1,
                      onTap: () => setState(() => _selectedMethod = 1),
                    ),
                    const SizedBox(height: 10),

                    // FPX
                    _PaymentMethodCard(
                      label: 'FPX',
                      subtitle: l10n.bankTransfer,
                      icon: Icons.account_balance_rounded,
                      isSelected: _selectedMethod == 2,
                      onTap: () => setState(() => _selectedMethod = 2),
                    ),

                    const SizedBox(height: 16),

                    // Fee breakdown
                    GlassBox(
                      blur: 12,
                      opacity: 0.3,
                      borderRadius: 16,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                            _feeRow(context, l10n.fuelContribution,
                              widget.ride.fuelShare),
                          const SizedBox(height: 6),
                            _feeRow(context, l10n.tollShare,
                              widget.ride.tollShare),
                          const SizedBox(height: 6),
                            _feeRow(context, l10n.platformFee,
                              widget.ride.platformFee),
                          Divider(height: 16, color: colors.divider),
                            _feeRow(context, l10n.total,
                              widget.ride.totalPrice, isBold: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: _processing
                    ? Center(
                        child: Container(
                          width: 56, height: 56,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.accentBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      )
                    : PillButton(
                        label: l10n.confirmPayment,
                        icon: Icons.lock_rounded,
                        expand: true,
                        onPressed: _confirmPayment,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feeRow(BuildContext context, String label, double amount,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isBold
                ? AppTextStyles.captionBold(context)
                : AppTextStyles.caption(context)),
        Text('RM ${amount.toStringAsFixed(2)}',
            style: isBold
                ? AppTextStyles.captionBold(context).copyWith(fontSize: 14)
                : AppTextStyles.caption(context)),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final activeColor = iconColor ?? AppColors.accentBlue;

    return GestureDetector(
      onTap: onTap,
      child: GlassBox(
        blur: 16,
        opacity: isSelected ? 0.55 : 0.25,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? activeColor.withValues(alpha: 0.1)
                    : colors.textTertiary.withValues(alpha: 0.08),
              ),
              child: Icon(icon, size: 20,
                  color: isSelected ? activeColor : colors.textTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.headline(context).copyWith(fontSize: 15)),
                  Text(subtitle, style: AppTextStyles.caption(context)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accentBlue : colors.textTertiary,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
