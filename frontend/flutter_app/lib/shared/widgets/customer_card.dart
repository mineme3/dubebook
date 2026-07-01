import 'package:flutter/material.dart';
import '../../core/models/customer.dart';
import '../../utils/theme.dart';
import 'components/saas_components.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int index;
  final bool isCustomerPortal;

  const CustomerCard({
    super.key,
    required this.customer,
    this.isSelected = false,
    required this.onTap,
    this.onLongPress,
    this.index = 0,
    this.isCustomerPortal = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = isCustomerPortal ? (customer.shop?.name ?? customer.fullName) : customer.fullName;
    final theme = Theme.of(context);
    final tokens = theme.extension<DubeTokens>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SaaSCard(
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: tokens.surfaceHigh,
              child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                  Text(customer.phone, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${customer.outstandingBalance.toStringAsFixed(0)} ETB', style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, color: customer.isOverdue ? AppTheme.error : AppTheme.primary)),
                if (customer.isOverdue)
                  Text('OVERDUE', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
