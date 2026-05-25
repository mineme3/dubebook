import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';
import '../database/config.dart';

class TelegramService {
  Future<bool> sendMessage({
    required String chatId,
    required String message,
  }) async {
    final botToken = Config.telegramBotToken;
    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': message,
          'parse_mode': 'HTML',
        }),
      );

      final success = response.statusCode == 200;
      
      // Log notification attempt to DB
      final db = await Config.db;
      await db.collection('notification_log').insertOne({
        '_id': ObjectId(),
        'chatId': chatId,
        'message': message,
        'sentAt': DateTime.now().toUtc(),
        'deliveryStatus': success ? 'sent' : 'failed',
        'errorMessage': success ? null : 'Status: ${response.statusCode}, Body: ${response.body}',
      });

      return success;
    } catch (e) {
      // Log error to DB
      final db = await Config.db;
      await db.collection('notification_log').insertOne({
        '_id': ObjectId(),
        'chatId': chatId,
        'message': message,
        'sentAt': DateTime.now().toUtc(),
        'deliveryStatus': 'failed',
        'errorMessage': e.toString(),
      });
      return false;
    }
  }

  Future<void> notifyOwnerDeadline({
    required String ownerChatId,
    required String customerName,
    required String customerPhone,
    required double outstanding,
    required List<String> overdueItemSummaries,
  }) async {
    final itemLines = overdueItemSummaries.map((s) => '• $s').join('\n');
    final message = '''
🔔 <b>Credit Reminder</b>
─────────────────
<b>Customer:</b> $customerName
<b>Phone:</b> $customerPhone
<b>Outstanding:</b> ${outstanding.toStringAsFixed(2)} ETB

<b>Overdue Items:</b>
$itemLines
''';
    await sendMessage(chatId: ownerChatId, message: message);
  }

  Future<void> notifyCustomerDeadline({
    required String customerChatId,
    required String customerName,
    required String shopName,
    required double outstanding,
    required DateTime deadline,
    required String ownerPhone,
  }) async {
    final message = '''
👋 Hello <b>$customerName</b>!

This is a reminder from <b>$shopName</b>.

You have an outstanding balance of <b>${outstanding.toStringAsFixed(2)} ETB</b>
that was due on ${_formatDate(deadline)}.

Please visit the shop or contact:
📞 $ownerPhone

Thank you!
''';
    await sendMessage(chatId: customerChatId, message: message);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
