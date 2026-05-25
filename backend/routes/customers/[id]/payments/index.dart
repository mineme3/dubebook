import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/database/config.dart';
import 'package:backend/services/credit_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final ownerId = context.read<String>();

  if (context.request.method == HttpMethod.get) {
    return _handleGet(context, ownerId, id);
  } else if (context.request.method == HttpMethod.post) {
    return _handlePost(context, ownerId, id);
  } else {
    return Response(statusCode: 405, body: 'Method not allowed');
  }
}

Future<Response> _handleGet(RequestContext context, String ownerId, String id) async {
  try {
    final db = await Config.db;
    final payments = await db.collection('payment_history').find(
      where.eq('customerId', ObjectId.fromHexString(id)).and(where.eq('ownerId', ObjectId.fromHexString(ownerId))),
    ).toList();

    final formatted = payments.map((p) {
      p['_id'] = (p['_id'] as ObjectId).oid;
      p['customerId'] = id;
      p['ownerId'] = ownerId;
      p['paidAt'] = (p['paidAt'] as DateTime).toIso8601String();
      p['createdAt'] = (p['createdAt'] as DateTime).toIso8601String();
      return p;
    }).toList();

    return Response.json(body: formatted);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}

Future<Response> _handlePost(RequestContext context, String ownerId, String id) async {
  try {
    final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
    final amountPaid = (body['amountPaid'] as num?)?.toDouble();
    final paymentMethod = body['paymentMethod'] as String?;
    final note = body['note'] as String?;

    if (amountPaid == null || paymentMethod == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required fields: amountPaid, paymentMethod'},
      );
    }

    final db = await Config.db;
    
    // Validate customer exists and belongs to this owner
    final customer = await db.collection('customers').findOne(
      where.id(ObjectId.fromHexString(id)).and(where.eq('ownerId', ObjectId.fromHexString(ownerId))),
    );

    if (customer == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Customer not found'},
      );
    }

    final creditService = CreditService();
    final newPayment = await creditService.recordPayment(
      customerId: id,
      ownerId: ownerId,
      amountPaid: amountPaid,
      method: paymentMethod,
      note: note,
    );

    return Response.json(statusCode: 201, body: newPayment);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
