import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:backend/database/config.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final body = jsonDecode(await context.request.body()) as Map<String, dynamic>;
    final token = body['token'] as String?;

    if (token == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Missing token parameter'},
      );
    }

    try {
      // Allow verifying expired token for refresh operations, or verify ignoring expiration
      final jwt = JWT.verify(token, SecretKey(Config.jwtSecret), checkHeaderType: false, checkExpiresIn: false);
      final ownerId = jwt.payload['sub'] as String;

      // Re-sign new token
      final newJwt = JWT(
        {'sub': ownerId},
        issuer: 'dubebook-backend',
      );

      final newToken = newJwt.sign(
        SecretKey(Config.jwtSecret),
        expiresIn: Duration(seconds: Config.jwtExpiry),
      );

      return Response.json(body: {'token': newToken});
    } on JWTException {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Invalid or corrupted token'},
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
