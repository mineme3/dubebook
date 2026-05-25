import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../database/config.dart';

Handler authMiddleware(Handler handler) {
  return (context) async {
    final authHeader = context.request.headers['Authorization'];

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Missing or invalid authorization header'},
      );
    }

    final token = authHeader.substring(7);

    try {
      final jwt = JWT.verify(token, SecretKey(Config.jwtSecret));
      final ownerId = jwt.payload['sub'] as String;

      // Provide the ownerId to the request context
      return handler(context.provide<String>(() => ownerId));
    } on JWTExpiredException {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Token expired'},
      );
    } on JWTException {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Invalid token'},
      );
    }
  };
}
