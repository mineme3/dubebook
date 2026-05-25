import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mocktail/mocktail.dart';
import 'package:dubebook/services/notification_service.dart';

class MockAndroidLocalNotifications extends Mock
    with MockPlatformInterfaceMixin
    implements AndroidFlutterLocalNotificationsPlugin {}

class FakeTZDateTime extends Fake implements tz.TZDateTime {}
class FakeAndroidNotificationDetails extends Fake implements AndroidNotificationDetails {}
class FakeAndroidInitializationSettings extends Fake implements AndroidInitializationSettings {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(FakeTZDateTime());
    registerFallbackValue(FakeAndroidNotificationDetails());
    registerFallbackValue(FakeAndroidInitializationSettings());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
  });

  group('NotificationService Tests', () {
    late MockAndroidLocalNotifications mockPlatform;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      mockPlatform = MockAndroidLocalNotifications();
      
      // Register the mock platform implementation
      FlutterLocalNotificationsPlatform.instance = mockPlatform;

      // Stub platform initialize method with correct named parameters
      when(() => mockPlatform.initialize(
            settings: any(named: 'settings'),
            onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
            onDidReceiveBackgroundNotificationResponse: any(named: 'onDidReceiveBackgroundNotificationResponse'),
          )).thenAnswer((_) async => true);

      // Stub requestNotificationsPermission
      when(() => mockPlatform.requestNotificationsPermission())
          .thenAnswer((_) async => true);

      // Stub zonedSchedule with named arguments
      when(() => mockPlatform.zonedSchedule(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            scheduleMode: any(named: 'scheduleMode'),
            payload: any(named: 'payload'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          )).thenAnswer((_) async => {});

      when(() => mockPlatform.cancel(
            id: any(named: 'id'),
          )).thenAnswer((_) async => {});
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('scheduleDeadlineNotification triggers correct platform calls', () async {
      final service = NotificationService();
      await service.init();
      
      // Schedule a deadline for yesterday. 
      // The logic in NotificationService will change this to 5 minutes from now.
      final deadline = DateTime.now().subtract(const Duration(days: 1));
      await service.scheduleDeadlineNotification(1, 'John Doe', deadline);

      verify(() => mockPlatform.zonedSchedule(
            id: 2,
            title: 'Payment Deadline: John Doe',
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            scheduleMode: any(named: 'scheduleMode'),
            payload: any(named: 'payload'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          )).called(1);
    });

    test('cancelNotification triggers cancel platform call', () async {
      final service = NotificationService();
      await service.init();

      await service.cancelNotification(1);

      verify(() => mockPlatform.cancel(id: 2)).called(1);
      verify(() => mockPlatform.cancel(id: 3)).called(1);
    });
  });
}
