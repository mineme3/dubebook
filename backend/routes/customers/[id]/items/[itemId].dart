import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/database/config.dart';
import 'package:backend/services/credit_service.dart';

Future<Response> onRequest(RequestContext context, String id, String itemId) async {
  final ownerId = context.read<String>();

  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final db = await Config.db;
    final itemObjId = ObjectId.fromHexString(itemId);
    final customerObjId = ObjectId.fromHexString(id);
    final ownerObjId = ObjectId.fromHexString(ownerId);

    // Validate item exists and belongs to this customer/owner
    final item = await db.collection('credit_items').findOne(
      where.id(itemObjId).and(where.eq('customerId', customerObjId)).and(where.eq('ownerId', ownerObjId)),
    );

    if (item == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'Credit item not found'},
      );
    }

    await db.collection('credit_items').deleteOne(where.id(itemObjId));

    // Recalculate customer's balance
    final creditService = CreditService();
    await creditService.recalculateCustomerBalance(id);

    return Response.json(body: {'success': true, 'message': 'Credit item deleted and balance recalculated'});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
