import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/database/config.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final ownerId = context.read<String>();

  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final db = await Config.db;
    final customerObjId = ObjectId.fromHexString(id);
    final ownerObjId = ObjectId.fromHexString(ownerId);

    final customer = await db.collection('customers').findOne(
      where.id(customerObjId).and(where.eq('ownerId', ownerObjId)),
    );

    if (customer == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Customer not found'},
      );
    }

    final items = await db.collection('credit_items').find(where.eq('customerId', customerObjId)).toList();
    final payments = await db.collection('payment_history').find(where.eq('customerId', customerObjId)).toList();

    // Map object IDs and formats to JSON serializable structures
    customer['_id'] = (customer['_id'] as ObjectId).oid;
    customer['ownerId'] = ownerId;
    customer['createdAt'] = (customer['createdAt'] as DateTime).toIso8601String();
    customer['updatedAt'] = (customer['updatedAt'] as DateTime).toIso8601String();

    final formattedItems = items.map((i) {
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

    final formattedPayments = payments.map((p) {
      p['_id'] = (p['_id'] as ObjectId).oid;
      p['customerId'] = id;
      p['ownerId'] = ownerId;
      p['paidAt'] = (p['paidAt'] as DateTime).toIso8601String();
      p['createdAt'] = (p['createdAt'] as DateTime).toIso8601String();
      return p;
    }).toList();

    return Response.json(
      body: {
        'customer': customer,
        'creditItems': formattedItems,
        'paymentHistory': formattedPayments,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
