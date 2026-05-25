import 'package:mongo_dart/mongo_dart.dart';
import '../database/config.dart';

class CreditService {
  Future<Map<String, dynamic>> addItem({
    required String customerId,
    required String ownerId,
    required String itemName,
    required String unitType,
    required double quantity,
    required double unitPrice,
    required DateTime deadline,
  }) async {
    final db = await Config.db;
    final totalPrice = quantity * unitPrice;
    final now = DateTime.now().toUtc();

    final item = {
      '_id': ObjectId(),
      'customerId': ObjectId.fromHexString(customerId),
      'ownerId': ObjectId.fromHexString(ownerId),
      'itemName': itemName,
      'unitType': unitType,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'deadline': deadline.toUtc(),
      'isPaid': false,
      'notifiedAt': null,
      'createdAt': now, // IMMUTABLE
      'updatedAt': now,
    };

    await db.collection('credit_items').insertOne(item);
    await recalculateCustomerBalance(customerId);
    
    // Convert ObjectIds to hex strings for JSON response
    item['_id'] = (item['_id'] as ObjectId).oid;
    item['customerId'] = customerId;
    item['ownerId'] = ownerId;
    item['deadline'] = (item['deadline'] as DateTime).toIso8601String();
    item['createdAt'] = (item['createdAt'] as DateTime).toIso8601String();
    item['updatedAt'] = (item['updatedAt'] as DateTime).toIso8601String();
    
    return item;
  }

  Future<Map<String, dynamic>> recordPayment({
    required String customerId,
    required String ownerId,
    required double amountPaid,
    required String method,
    String? note,
  }) async {
    final db = await Config.db;
    final customer = await db.collection('customers').findOne(where.id(ObjectId.fromHexString(customerId)));
    
    if (customer == null) {
      throw Exception('Customer not found');
    }

    final balanceBefore = (customer['outstandingBalance'] as num?)?.toDouble() ?? 0.0;
    final balanceAfter = (balanceBefore - amountPaid).clamp(0.0, double.infinity);
    final now = DateTime.now().toUtc();

    final payment = {
      '_id': ObjectId(),
      'customerId': ObjectId.fromHexString(customerId),
      'ownerId': ObjectId.fromHexString(ownerId),
      'amountPaid': amountPaid,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'paymentMethod': method,
      'note': note,
      'paidAt': now,
      'createdAt': now,
    };

    await db.collection('payment_history').insertOne(payment);
    await recalculateCustomerBalance(customerId);

    // Convert ObjectIds to hex strings for JSON response
    payment['_id'] = (payment['_id'] as ObjectId).oid;
    payment['customerId'] = customerId;
    payment['ownerId'] = ownerId;
    payment['paidAt'] = (payment['paidAt'] as DateTime).toIso8601String();
    payment['createdAt'] = (payment['createdAt'] as DateTime).toIso8601String();

    return payment;
  }

  Future<void> recalculateCustomerBalance(String customerId) async {
    final db = await Config.db;
    final customerObjId = ObjectId.fromHexString(customerId);

    final items = await db.collection('credit_items').find(where.eq('customerId', customerObjId)).toList();
    final payments = await db.collection('payment_history').find(where.eq('customerId', customerObjId)).toList();

    final totalDebt = items.fold<double>(0, (s, i) => s + ((i['totalPrice'] as num?)?.toDouble() ?? 0.0));
    final totalPaid = payments.fold<double>(0, (s, p) => s + ((p['amountPaid'] as num?)?.toDouble() ?? 0.0));
    final outstanding = (totalDebt - totalPaid).clamp(0.0, double.infinity);

    String status = 'active';
    if (outstanding == 0.0) {
      status = 'settled';
    } else {
      // Check if any unpaid items have passed their deadlines
      final now = DateTime.now().toUtc();
      final hasOverdue = items.any((i) {
        final isPaid = i['isPaid'] as bool? ?? false;
        final deadline = i['deadline'] as DateTime?;
        return !isPaid && deadline != null && deadline.isBefore(now);
      });
      if (hasOverdue) {
        status = 'overdue';
      }
    }

    await db.collection('customers').updateOne(
      where.id(customerObjId),
      modify
        .set('totalDebt', totalDebt)
        .set('totalPaid', totalPaid)
        .set('outstandingBalance', outstanding)
        .set('status', status)
        .set('updatedAt', DateTime.now().toUtc()),
    );
  }
}
