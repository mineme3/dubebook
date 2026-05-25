import 'package:flutter/material.dart';
import '../../core/models/customer.dart';
import '../../utils/theme.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int index;

  const CustomerCard({
    super.key,
    required this.customer,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
    this.index = 0,
  });

  Color get _statusColor {
    switch (customer.status) {
      case 'overdue':
        return AppTheme.error;
      case 'settled':
        return AppTheme.accentGreen;
      default:
        return AppTheme.primaryBlue;
    }
  }

  String get _statusLabel {
    switch (customer.status) {
      case 'overdue':
        return 'OVERDUE';
      case 'settled':
        return 'SETTLED';
      default:
        return 'ACTIVE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 80)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.05)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryBlue
                  : customer.isOverdue
                      ? AppTheme.error.withOpacity(0.4)
                      : AppTheme.textSecondary.withOpacity(0.1),
              width: isSelected ? 2.0 : (customer.isOverdue ? 1.5 : 1),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [
                            AppTheme.primaryBlue,
                            AppTheme.primaryBlue.withOpacity(0.8)
                          ]
                        : [
                            _statusColor.withOpacity(0.15),
                            _statusColor.withOpacity(0.05)
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 24)
                      : Text(
                          customer.fullName[0].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: _statusColor,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 18),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            customer.phone,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Balance + Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${customer.outstandingBalance.toStringAsFixed(0)} ETB',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: customer.isSettled
                          ? AppTheme.accentGreen
                          : customer.isOverdue
                              ? AppTheme.error
                              : AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: _statusColor,
                        letterSpacing: 1,
                      ),
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
