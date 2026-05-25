import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  // Under stateless JWT design, logout is handled on client by wiping secure storage.
  // We simply return a success message.
  return Response.json(body: {'message': 'Logged out successfully'});
}
