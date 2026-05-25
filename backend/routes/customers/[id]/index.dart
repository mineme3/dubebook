import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/database/config.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final ownerId = context.read<String>();

  if (context.request.method == HttpMethod.get) {
    return _handleGet(context, ownerId, id);
  } else if (context.request.method == HttpMethod.patch) {
    return _handlePatch(context, ownerId, id);
  } else if (context.request.method == HttpMethod.delete) {
    return _handleDelete(context, ownerId, id);
  } else {
    return Response(statusCode: 405, body: 'Method not allowed');
  }
}

Future<Response> _handleGet(RequestContext context, String ownerId, String id) async {
  try {
    final db = await Config.db;
    final collection = db.collection('customers');

    final customer = await collection.findOne(
      where.id(ObjectId.fromHexString(id)).and(where.eq('ownerId', ObjectId.fromHexString(ownerId))),
    );

    if (customer == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Customer not found'},
      );
    }

    customer['_id'] = (customer['_id'] as ObjectId).oid;
    customer['ownerId'] = ownerId;
    customer['createdAt'] = (customer['createdAt'] as DateTime).toIso8601String();
    customer['updatedAt'] = (customer['updatedAt'] as DateTime).toIso8601String();

    return Response.json(body: customer);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}

Future<Response> _handlePatch(RequestContext context, String ownerId, String id) async {
  try {
    final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
    final db = await Config.db;
    final collection = db.collection('customers');

    final customerObjId = ObjectId.fromHexString(id);
    final customer = await collection.findOne(
      where.id(customerObjId).and(where.eq('ownerId', ObjectId.fromHexString(ownerId))),
    );

    if (customer == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Customer not found'},
      );
    }

    final updateData = modify;
    
    // Whitelist only editable properties
    if (body.containsKey('fullName')) {
      updateData.set('fullName', body['fullName']);
    }
    if (body.containsKey('phone')) {
      updateData.set('phone', body['phone']);
    }
    if (body.containsKey('telegramUsername')) {
      updateData.set('telegramUsername', body['telegramUsername']);
    }
    if (body.containsKey('telegramChatId')) {
      updateData.set('telegramChatId', body['telegramChatId']);
    }
    if (body.containsKey('address')) {
      updateData.set('address', body['address']);
    }
    if (body.containsKey('notes')) {
      updateData.set('notes', body['notes']);
    }
    
    updateData.set('updatedAt', DateTime.now().toUtc());

    await collection.updateOne(where.id(customerObjId), updateData);

    final updatedCustomer = await collection.findOne(where.id(customerObjId));
    updatedCustomer!['_id'] = (updatedCustomer['_id'] as ObjectId).oid;
    updatedCustomer['ownerId'] = ownerId;
    updatedCustomer['createdAt'] = (updatedCustomer['createdAt'] as DateTime).toIso8601String();
    updatedCustomer['updatedAt'] = (updatedCustomer['updatedAt'] as DateTime).toIso8601String();

    return Response.json(body: updatedCustomer);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}

Future<Response> _handleDelete(RequestContext context, String ownerId, String id) async {
  try {
    final db = await Config.db;
    final collection = db.collection('customers');

    final customerObjId = ObjectId.fromHexString(id);
    final customer = await collection.findOne(
      where.id(customerObjId).and(where.eq('ownerId', ObjectId.fromHexString(ownerId))),
    );

    if (customer == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Customer not found'},
      );
    }

    // Perform hard-delete cascades (delete customer's items and payments too)
    await collection.deleteOne(where.id(customerObjId));
    await db.collection('credit_items').deleteMany(where.eq('customerId', customerObjId));
    await db.collection('payment_history').deleteMany(where.eq('customerId', customerObjId));

    return Response.json(body: {'success': true, 'message': 'Customer and associated data deleted successfully'});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
