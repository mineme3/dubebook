import 'package:flutter/material.dart';
import '../../core/models/credit_item.dart';
import '../../utils/theme.dart';
import '../../utils/ethiopian_calendar.dart';

class CreditItemCard extends StatelessWidget {
  final CreditItem item;
  final String locale;
  final VoidCallback? onDelete;

  const CreditItemCard({
    super.key,
    required this.item,
    this.locale = 'en',
    this.onDelete,
  });

  Color get _deadlineColor {
    if (item.isPaid) return AppTheme.accentGreen;
    if (item.isOverdue) return AppTheme.error;
    if (item.isUpcoming) return const Color(0xFFFF9800); // Amber
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: item.isOverdue
              ? AppTheme.error.withOpacity(0.3)
              : AppTheme.textSecondary.withOpacity(0.1),
          width: item.isOverdue ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: item name + price + actions
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.shopping_cart_rounded,
                  size: 20,
                  color: item.isPaid
                      ? AppTheme.accentGreen
                      : AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                        decoration: item.isPaid
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.metadataDisplay,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.totalPrice.toStringAsFixed(0)} ETB',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: item.isPaid
                      ? AppTheme.accentGreen
                      : AppTheme.primaryBlue,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.error, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Metadata row: deadline + created date
          Row(
            children: [
              Icon(Icons.event_rounded, size: 14, color: _deadlineColor),
              const SizedBox(width: 6),
              Text(
                'Deadline: ${EthiopianCalendar.fromGregorian(item.deadline).format(locale: locale)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _deadlineColor,
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time_rounded,
                  size: 13, color: AppTheme.textSecondary.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                EthiopianCalendar.fromGregorian(item.createdAt).format(locale: locale),
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // Overdue/Upcoming badge
          if (item.isOverdue || item.isUpcoming) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _deadlineColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.isOverdue ? '⚠ OVERDUE' : '⏰ DUE SOON',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _deadlineColor,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
