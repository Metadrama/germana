import 'package:flutter/material.dart';
import 'package:germana/core/glass_box.dart';
import 'package:germana/core/theme.dart';
import 'package:germana/data/mock_ledger.dart';
import 'package:germana/models/ride_model.dart';
import 'package:germana/widgets/section_label.dart';
import 'package:intl/intl.dart';

/// Ledger tab — financial transparency with Malay labels.
class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalSpent = mockLedger
        .where((e) => e.amount < 0)
        .fold(0.0, (sum, e) => sum + e.amount.abs());
    final totalRefunded = mockLedger
        .where((e) => e.type == TransactionType.refund)
        .fold(0.0, (sum, e) => sum + e.amount);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text('History', style: AppTextStyles.display(context)),
          const SizedBox(height: 20),

          // Summary hero card
          GlassBox(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bulan ini', style: AppTextStyles.caption(context)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jumlah belanja',
                              style: AppTextStyles.bodySecondary(context)),
                          Text(
                            'RM ${totalSpent.toStringAsFixed(2)}',
                            style: AppTextStyles.price(context)
                                .copyWith(fontSize: 28),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1, height: 40,
                      color: GermanaColors.of(context).glassBorder,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dikembalikan',
                                style: AppTextStyles.bodySecondary(context)),
                            Text(
                              'RM ${totalRefunded.toStringAsFixed(2)}',
                              style: AppTextStyles.price(context).copyWith(
                                fontSize: 28,
                                color: AppColors.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionLabel(label: 'Receipts'),

          ...mockLedger.map((entry) => _TransactionTile(entry: entry)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final LedgerEntry entry;
  const _TransactionTile({required this.entry});

  Color get _indicatorColor {
    switch (entry.type) {
      case TransactionType.escrowHold:
        return AppColors.escrowBlue;
      case TransactionType.platformFee:
        return AppColors.feeNeutral;
      case TransactionType.releasedToDriver:
        return AppColors.releasedGreen;
      case TransactionType.refund:
        return AppColors.refundAmber;
    }
  }

  String get _typeLabel {
    switch (entry.type) {
      case TransactionType.escrowHold:
        return 'Simpanan Escrow';
      case TransactionType.platformFee:
        return 'Yuran Platform';
      case TransactionType.releasedToDriver:
        return 'Dikeluarkan';
      case TransactionType.refund:
        return 'Bayaran Balik';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = entry.amount > 0;

    return GlassBox(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      opacity: 0.35,
      child: Row(
        children: [
          Container(
            width: 4, height: 36,
            decoration: BoxDecoration(
              color: _indicatorColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_typeLabel,
                        style: AppTextStyles.captionBold(context)
                            .copyWith(fontSize: 13)),
                    const Spacer(),
                    Text(
                      '${isPositive ? '+' : '-'}RM ${entry.amount.abs().toStringAsFixed(2)}',
                      style: AppTextStyles.headline(context).copyWith(
                        fontSize: 15,
                        color: isPositive
                            ? AppColors.accentGreen
                            : GermanaColors.of(context).textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (entry.rideRoute != null) ...[
                      Text(entry.rideRoute!,
                          style: AppTextStyles.caption(context)),
                      Text(' · ', style: AppTextStyles.caption(context)),
                    ],
                    Text(_formatDate(entry.date),
                        style: AppTextStyles.caption(context)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 24) return 'Hari ini ${DateFormat('HH:mm').format(dt)}';
    if (diff.inDays < 7) return '${diff.inDays} hari lepas';
    return DateFormat('d MMM').format(dt);
  }
}
