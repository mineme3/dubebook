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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.textMuted.withOpacity(0.1),
          width: 1,
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
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.shopping_cart_rounded,
                  size: 20,
                  color: item.isPaid
                      ? AppTheme.primary
                      : AppTheme.primary,
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
                        color: AppTheme.textMuted,
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
                      ? AppTheme.primary
                      : AppTheme.primary,
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
          // Metadata row: status + created date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (item.isPaid ? AppTheme.primary : AppTheme.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.isPaid ? 'PAID' : 'UNPAID',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: item.isPaid ? AppTheme.primary : AppTheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time_rounded,
                  size: 13, color: AppTheme.textMuted.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                EthiopianCalendar.fromGregorian(item.createdAt).format(locale: locale),
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
