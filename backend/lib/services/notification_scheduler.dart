import 'package:mongo_dart/mongo_dart.dart';
import '../database/config.dart';
import 'telegram_service.dart';

class NotificationScheduler {
  Future<void> runDailyDeadlineCheck() async {
    final db = await Config.db;
    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day);

    // Find all unpaid items whose deadline is today or past
    final overdueItems = await db.collection('credit_items').find({
      'isPaid': false,
      'deadline': {'\$lte': today},
    }).toList();

    if (overdueItems.isEmpty) return;

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in overdueItems) {
      final customerId = (item['customerId'] as ObjectId).oid;
      grouped.putIfAbsent(customerId, () => []).add(item);
    }

    final telegramService = TelegramService();

    for (final entry in grouped.entries) {
      final customerId = entry.key;
      final items = entry.value;

      final customer = await db.collection('customers').findOne(where.id(ObjectId.fromHexString(customerId)));
      if (customer == null) continue;

      final ownerId = customer['ownerId'] as ObjectId?;
      if (ownerId == null) continue;

      final owner = await db.collection('owners').findOne(where.id(ownerId));
      if (owner == null) continue;

      // 1. Notify Owner
      final ownerChatId = owner['telegramChatId'] as String?;
      if (ownerChatId != null && ownerChatId.isNotEmpty) {
        final summaries = items.map((i) {
          final name = i['itemName'] as String? ?? 'Item';
          final qty = i['quantity'] ?? 0;
          final unit = i['unitType'] ?? 'units';
          return '$name ($qty $unit)';
        }).toList();

        await telegramService.notifyOwnerDeadline(
          ownerChatId: ownerChatId,
          customerName: customer['fullName'] as String? ?? 'Unknown',
          customerPhone: customer['phone'] as String? ?? 'N/A',
          outstanding: ((customer['outstandingBalance'] as num?)?.toDouble() ?? 0.0),
          overdueItemSummaries: summaries,
        );
      }

      // 2. Notify Customer
      final customerChatId = customer['telegramChatId'] as String?;
      if (customerChatId != null && customerChatId.isNotEmpty) {
        // Find earliest deadline in the overdue items group
        DateTime earliestDeadline = today;
        if (items.isNotEmpty) {
          final firstDeadline = items.first['deadline'] as DateTime?;
          if (firstDeadline != null) {
            earliestDeadline = firstDeadline;
          }
        }

        await telegramService.notifyCustomerDeadline(
          customerChatId: customerChatId,
          customerName: customer['fullName'] as String? ?? 'Valued Customer',
          shopName: owner['shopName'] as String? ?? 'Shop',
          outstanding: ((customer['outstandingBalance'] as num?)?.toDouble() ?? 0.0),
          deadline: earliestDeadline,
          ownerPhone: owner['phone'] as String? ?? 'N/A',
        );
      }
    }
  }
}
