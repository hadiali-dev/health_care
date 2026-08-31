import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Call once in main(), before runApp(). [onNotificationTap] fires when
  /// the user taps a shown notification — wired to navigation in main.dart,
  /// so this service stays decoupled from routing entirely.
  Future<void> initialize({required void Function() onNotificationTap}) async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) => onNotificationTap(),
    );

    // Android 13+ requires this runtime permission or notifications never show.
    await Permission.notification.request();

    _initialized = true;
  }

  Future<void> showNearbyPatientAlert(int nearbyCount) async {
    const androidDetails = AndroidNotificationDetails(
      'nearby_patients_channel',
      'Nearby Patient Alerts',
      channelDescription: 'Alerts when patients marked unhealthy are nearby.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      'Nearby Patient Alert',
      nearbyCount == 1
          ? 'There is 1 nearby patient marked unhealthy.'
          : 'There are $nearbyCount nearby patients marked unhealthy.',
      details,
    );
  }
}
