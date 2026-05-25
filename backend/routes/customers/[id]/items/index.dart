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
    final items = await db.collection('credit_items').find(
      where.eq('customerId', ObjectId.fromHexString(id)).and(where.eq('ownerId', ObjectId.fromHexString(ownerId))),
    ).toList();

    final formatted = items.map((i) {
      i['_id'] = (i['_id'] as ObjectId).oid;
      i['customerId'] = id;
      i['ownerId'] = ownerId;
      i['deadline'] = (i['deadline'] as DateTime).toIso8601String();
      if (i['notifiedAt'] != null) {
        i['notifiedAt'] = (i['notifiedAt'] as DateTime).toIso8601String();
      }
      i['createdAt'] = (i['createdAt'] as DateTime).toIso8601String();
      i['updatedAt'] = (i['updatedAt'] as DateTime).toIso8601String();
      return i;
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
    final itemName = body['itemName'] as String?;
    final unitType = body['unitType'] as String?;
    final quantity = (body['quantity'] as num?)?.toDouble();
    final unitPrice = (body['unitPrice'] as num?)?.toDouble();
    final deadlineStr = body['deadline'] as String?;

    if (itemName == null || unitType == null || quantity == null || unitPrice == null || deadlineStr == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required fields: itemName, unitType, quantity, unitPrice, deadline'},
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
    final newItem = await creditService.addItem(
      customerId: id,
      ownerId: ownerId,
      itemName: itemName,
      unitType: unitType,
      quantity: quantity,
      unitPrice: unitPrice,
      deadline: DateTime.parse(deadlineStr),
    );

    return Response.json(statusCode: 201, body: newItem);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
