import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/database/config.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (email == null || password == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing email or password'},
      );
    }

    final db = await Config.db;
    final collection = db.collection('owners');

    final owner = await collection.findOne(where.eq('email', email));

    if (owner == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Invalid email or password'},
      );
    }

    final passwordHash = owner['passwordHash'] as String;
    if (!BCrypt.checkpw(password, passwordHash)) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Invalid email or password'},
      );
    }

    final ownerId = (owner['_id'] as ObjectId).oid;

    // Create JWT
    final jwt = JWT(
      {'sub': ownerId},
      issuer: 'dubebook-backend',
    );

    final token = jwt.sign(
      SecretKey(Config.jwtSecret),
      expiresIn: Duration(seconds: Config.jwtExpiry),
    );

    return Response.json(
      body: {
        'token': token,
        'owner': {
          'id': ownerId,
          'fullName': owner['fullName'],
          'phone': owner['phone'],
          'email': owner['email'],
          'telegramChatId': owner['telegramChatId'],
          'shopName': owner['shopName'],
        }
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
