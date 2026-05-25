import 'package:dart_frog/dart_frog.dart';
import 'package:backend/services/notification_scheduler.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    final scheduler = NotificationScheduler();
    await scheduler.runDailyDeadlineCheck();

    return Response.json(body: {'success': true, 'message': 'Daily deadline notification sweep executed successfully'});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Internal server error', 'details': e.toString()},
    );
  }
}
