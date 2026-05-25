import 'package:flutter/material.dart';
import '../../core/models/payment_record.dart';
import '../../utils/theme.dart';
import '../../utils/ethiopian_calendar.dart';

class PaymentCard extends StatelessWidget {
  final PaymentRecord payment;
  final String locale;

  const PaymentCard({
    super.key,
    required this.payment,
    this.locale = 'en',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.accentGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Payment Received',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                '+${payment.amountPaid.toStringAsFixed(0)} ETB',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppTheme.accentGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Balance change row
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [
                _balanceChip(
                  'Before',
                  '${payment.balanceBefore.toStringAsFixed(0)} ETB',
                  AppTheme.textSecondary,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 18, color: AppTheme.accentGreen),
                ),
                _balanceChip(
                  'After',
                  '${payment.balanceAfter.toStringAsFixed(0)} ETB',
                  payment.balanceAfter == 0
                      ? AppTheme.accentGreen
                      : AppTheme.primaryBlue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Footer: method + timestamp
          Row(
            children: [
              Icon(Icons.payment_rounded,
                  size: 14, color: AppTheme.textSecondary.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text(
                payment.paymentMethodLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
              if (payment.note != null && payment.note!.isNotEmpty) ...[
                const SizedBox(width: 12),
                Icon(Icons.note_rounded,
                    size: 13, color: AppTheme.textSecondary.withOpacity(0.5)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    payment.note!,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const Spacer(),
              Icon(Icons.access_time_rounded,
                  size: 13, color: AppTheme.textSecondary.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                EthiopianCalendar.fromGregorian(payment.paidAt).format(locale: locale),
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceChip(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary.withOpacity(0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
