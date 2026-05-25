import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class BalanceSummaryWidget extends StatelessWidget {
  final double totalDebt;
  final double totalPaid;
  final double outstandingBalance;
  final String status;

  const BalanceSummaryWidget({
    super.key,
    required this.totalDebt,
    required this.totalPaid,
    required this.outstandingBalance,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'OUTSTANDING BALANCE',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${outstandingBalance.toStringAsFixed(2)} ETB',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: outstandingBalance == 0
                  ? AppTheme.accentGreen
                  : status == 'overdue'
                      ? AppTheme.error
                      : AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          // Debt / Paid row
          Row(
            children: [
              _summaryItem(
                icon: Icons.trending_up_rounded,
                iconColor: AppTheme.error,
                label: 'Total Debt',
                value: '${totalDebt.toStringAsFixed(0)} ETB',
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textSecondary.withOpacity(0.1),
              ),
              _summaryItem(
                icon: Icons.trending_down_rounded,
                iconColor: AppTheme.accentGreen,
                label: 'Total Paid',
                value: '${totalPaid.toStringAsFixed(0)} ETB',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
