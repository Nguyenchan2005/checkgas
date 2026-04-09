import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static DateTime _lastNotificationTime = DateTime.now();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  static Future<void> showAlarmNotification(String message) async {
    if (DateTime.now().difference(_lastNotificationTime).inSeconds < 10) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'gas_alarm_channel',
      'Cảnh báo Khí Gas',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      color: Colors.red,
    );

    await _plugin.show(
      0,
      '⚠️ NGUY HIỂM!',
      'Trạng thái: $message',
      const NotificationDetails(android: androidDetails),
    );

    _lastNotificationTime = DateTime.now();
  }
}
