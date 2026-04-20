import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/l10n/app_localizations.dart';
import 'package:germana/widgets/pill_button.dart';

/// Booking confirmed — driver identity reveal with blur → sharp animation.
class BookingConfirmedScreen extends StatefulWidget {
  final RideModel ride;
  final bool pendingApproval;

  const BookingConfirmedScreen({
    super.key,
    required this.ride,
    this.pendingApproval = false,
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _revealController;
  late Animation<double> _checkScale;
  late Animation<double> _revealBlur;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _revealBlur = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutCubic),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutCubic),
    );

    _checkController.forward();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _revealController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated checkmark
              ScaleTransition(
                scale: _checkScale,
                child: Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentGreen.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 48, color: AppColors.accentGreen),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                widget.pendingApproval ? 'Request sent' : l10n.securedTitle,
                style: AppTextStyles.display(context),
              ),
              const SizedBox(height: 8),
              Text(
                widget.pendingApproval
                    ? 'Your request is pending driver approval.'
                    : '${widget.ride.origin} → ${widget.ride.destination}',
                style: AppTextStyles.bodySecondary(context),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              if (!widget.pendingApproval)
                AnimatedBuilder(
                  animation: _revealController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideUp,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: _revealBlur.value,
                          sigmaY: _revealBlur.value,
                        ),
                        child: Opacity(
                          opacity: _revealController.value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: GlassBox(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(l10n.yourDriver,
                            style: AppTextStyles.caption(context)),
                        const SizedBox(height: 12),

                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentBlue.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: Text(
                              widget.ride.driverInitials,
                              style: AppTextStyles.title(context)
                                  .copyWith(color: AppColors.accentBlue),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text(widget.ride.driverDisplayName,
                            style: AppTextStyles.title(context)),
                        const SizedBox(height: 4),
                        Text('${widget.ride.carModel} · White',
                            style: AppTextStyles.bodySecondary(context)),
                        const SizedBox(height: 4),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: GermanaColors.of(context)
                                .textPrimary
                                .withValues(alpha: 0.06),
                            borderRadius:
                                BorderRadius.circular(AppRadius.chip),
                          ),
                            child: Text(widget.ride.carPlate ?? 'WXY 1234',
                              style: AppTextStyles.captionBold(context)
                                  .copyWith(letterSpacing: 1.5)),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PillButton(
                              label: l10n.chatDriver,
                              icon: Icons.chat_bubble_outline_rounded,
                              isSmall: true,
                              isOutlined: true,
                              onPressed: () {},
                            ),
                            const SizedBox(width: 12),
                            PillButton(
                              label: l10n.callDriver,
                              icon: Icons.phone_outlined,
                              isSmall: true,
                              isOutlined: true,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else
                GlassBox(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_top_rounded, color: AppColors.accentAmber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Driver will review your request soon. You will see updates in My Rides.',
                          style: AppTextStyles.caption(context),
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: l10n.viewRide,
                  expand: true,
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
