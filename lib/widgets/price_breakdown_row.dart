import 'package:flutter/material.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/l10n/app_localizations.dart';

/// Expandable price breakdown row — fuel / toll / platform fee splits.
class PriceBreakdownRow extends StatefulWidget {
  final double fuelShare;
  final double tollShare;
  final double platformFee;

  const PriceBreakdownRow({
    super.key,
    required this.fuelShare,
    required this.tollShare,
    required this.platformFee,
  });

  @override
  State<PriceBreakdownRow> createState() => _PriceBreakdownRowState();
}

class _PriceBreakdownRowState extends State<PriceBreakdownRow>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = GermanaColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.priceBreakdownTitle,
                style: AppTextStyles.caption(context).copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ClipRect(
          child: SizeTransition(
            sizeFactor: _heightFactor,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  _line(context, l10n.fuelShareLabel, widget.fuelShare),
                  const SizedBox(height: 4),
                  _line(context, l10n.tollShareLabel, widget.tollShare),
                  const SizedBox(height: 4),
                  _line(context, l10n.platformFeeLabel, widget.platformFee),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _line(BuildContext context, String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption(context)),
        Text(
          'RM ${amount.toStringAsFixed(2)}',
          style: AppTextStyles.captionBold(context),
        ),
      ],
    );
  }
}
