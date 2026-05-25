import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/database/config.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
    final fullName = body['fullName'] as String?;
    final phone = body['phone'] as String?;
    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final telegramChatId = body['telegramChatId'] as String?;
    final shopName = body['shopName'] as String?;

    if (fullName == null || phone == null || email == null || password == null || shopName == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing required fields: fullName, phone, email, password, shopName'},
      );
    }

    final db = await Config.db;
    final collection = db.collection('owners');

    // Check if email or phone already exists
    final existing = await collection.findOne(
      where.eq('email', email).or(where.eq('phone', phone)),
    );

    if (existing != null) {
      return Response.json(
        statusCode: 409,
        body: {'error': 'User with this email or phone already exists'},
      );
    }

    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: 12));
    final now = DateTime.now().toUtc();
    final ownerId = ObjectId();

    await collection.insertOne({
      '_id': ownerId,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'passwordHash': passwordHash,
      'telegramChatId': telegramChatId,
      'shopName': shopName,
      'createdAt': now,
      'updatedAt': now,
    });

    return Response.json(
      statusCode: 201,
      body: {
        'message': 'Owner registered successfully',
        'ownerId': ownerId.oid,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
