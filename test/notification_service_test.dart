import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:dubebook/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationService Tests', () {
    final List<MethodCall> methodCalls = [];
    const MethodChannel channel = MethodChannel('dexterous.com/flutter/local_notifications');

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      methodCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        methodCalls.add(methodCall);
        if (methodCall.method == 'initialize') {
          return true;
        }
        return null;
      });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    testWidgets('scheduleDeadlineNotification triggers correct method channel calls', (WidgetTester tester) async {
      final service = NotificationService();
      await service.init();
      
      // Clear calls from init
      methodCalls.clear();

      // Schedule a deadline for yesterday. 
      // The logic in NotificationService will change this to 5 minutes from now.
      final deadline = DateTime.now().subtract(const Duration(days: 1));
      await service.scheduleDeadlineNotification(1, 'John Doe', deadline);

      // On Android/iOS, it directly calls zonedSchedule
      final zonedCalls = methodCalls.where((c) => c.method == 'zonedSchedule').toList();
      expect(zonedCalls.isNotEmpty, true, reason: 'Expected zonedSchedule to be called');
      expect(zonedCalls.first.arguments['title'], 'Payment Deadline: John Doe');
    });

    testWidgets('cancelNotification triggers cancel method channel call', (WidgetTester tester) async {
      final service = NotificationService();
      await service.init();
      methodCalls.clear();

      await service.cancelNotification(1);

      final cancelCalls = methodCalls.where((c) => c.method == 'cancel').toList();
      // Should cancel ID * 2 and ID * 2 + 1
      expect(cancelCalls.length, 2);
      expect(cancelCalls[0].arguments, 2); // ID * 2
      expect(cancelCalls[1].arguments, 3); // ID * 2 + 1
    });
  });
}
