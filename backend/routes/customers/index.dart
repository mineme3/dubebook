import 'dart:convert';
import 'dart:math';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/database/config.dart';

Future<Response> onRequest(RequestContext context) async {
  final ownerId = context.read<String>();
  
  if (context.request.method == HttpMethod.get) {
    return _handleGet(context, ownerId);
  } else if (context.request.method == HttpMethod.post) {
    return _handlePost(context, ownerId);
  } else {
    return Response(statusCode: 405, body: 'Method not allowed');
  }
}

Future<Response> _handleGet(RequestContext context, String ownerId) async {
  try {
    final db = await Config.db;
    final collection = db.collection('customers');
    
    final list = await collection.find(where.eq('ownerId', ObjectId.fromHexString(ownerId))).toList();
    
    // Format ObjectIds to hex strings for JSON response
    final formatted = list.map((c) {
      c['_id'] = (c['_id'] as ObjectId).oid;
      c['ownerId'] = ownerId;
      c['createdAt'] = (c['createdAt'] as DateTime).toIso8601String();
      c['updatedAt'] = (c['updatedAt'] as DateTime).toIso8601String();
      return c;
    }).toList();
    
    return Response.json(body: formatted);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}

Future<Response> _handlePost(RequestContext context, String ownerId) async {
  try {
    final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
    final fullName = body['fullName'] as String?;
    final phone = body['phone'] as String?;
    final telegramUsername = body['telegramUsername'] as String? ?? '';
    final address = body['address'] as String? ?? '';
    final notes = body['notes'] as String? ?? '';

    if (fullName == null || phone == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required fields: fullName, phone'},
      );
    }

    final db = await Config.db;
    final collection = db.collection('customers');

    // Enforce unique phone per owner
    final existing = await collection.findOne(
      where.eq('ownerId', ObjectId.fromHexString(ownerId)).and(where.eq('phone', phone)),
    );

    if (existing != null) {
      return Response.json(
        statusCode: 409,
        body: {'error': 'Customer with this phone already registered under your account'},
      );
    }

    // Generate human-readable customerId: CUST-YYYYMMDD-XXXX
    final now = DateTime.now().toUtc();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomSuffix = _generateRandomSuffix();
    final customerIdStr = 'CUST-$dateStr-$randomSuffix';

    final customer = {
      '_id': ObjectId(),
      'ownerId': ObjectId.fromHexString(ownerId),
      'customerId': customerIdStr,
      'fullName': fullName,
      'phone': phone,
      'telegramUsername': telegramUsername,
      'telegramChatId': null, // Resolved on first Telegram interaction
      'address': address,
      'notes': notes,
      'totalDebt': 0.0,
      'totalPaid': 0.0,
      'outstandingBalance': 0.0,
      'status': 'active',
      'createdAt': now,
      'updatedAt': now,
    };

    await collection.insertOne(customer);

    // Convert ObjectIds to strings for response
    customer['_id'] = (customer['_id'] as ObjectId).oid;
    customer['ownerId'] = ownerId;
    customer['createdAt'] = now.toIso8601String();
    customer['updatedAt'] = now.toIso8601String();

    return Response.json(statusCode: 201, body: customer);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}

String _generateRandomSuffix() {
  final r = Random();
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(4, (index) => chars[r.nextInt(chars.length)]).join();
}
