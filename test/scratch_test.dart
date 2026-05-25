import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';

class FakeLinuxFlutterLocalNotificationsPlugin extends LinuxFlutterLocalNotificationsPlugin {
  FakeLinuxFlutterLocalNotificationsPlugin() : super();

  @override
  Future<bool?> initialize(
    LinuxInitializationSettings initializationSettings, {
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    return true;
  }
}

void main() {
  test('test setting platform instance', () {
    final fakePlatform = FakeLinuxFlutterLocalNotificationsPlugin();
    FlutterLocalNotificationsPlatform.instance = fakePlatform;
    expect(FlutterLocalNotificationsPlatform.instance, fakePlatform);
  });
}
