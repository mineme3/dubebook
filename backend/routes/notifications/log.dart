import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/database/config.dart';

Future<Response> onRequest(RequestContext context) async {
  final ownerId = context.read<String>();

  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final db = await Config.db;
    final logs = await db
        .collection('notification_log')
        .find(where.eq('ownerId', ObjectId.fromHexString(ownerId)))
        .toList();

    final formatted = logs.map((l) {
      l['_id'] = (l['_id'] as ObjectId).oid;
      if (l['customerId'] is ObjectId) {
        l['customerId'] = (l['customerId'] as ObjectId).oid;
      }
      l['ownerId'] = ownerId;
      l['sentAt'] = (l['sentAt'] as DateTime).toIso8601String();
      return l;
    }).toList();

    return Response.json(body: formatted);
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
