import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ai_partner/logic/cubit/settings/settings_cubit.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final SettingsCubit _settingsCubit;

  NotificationService(this._settingsCubit);

  static const String _channelId = 'ai_partner_channel';
  static const String _channelName = 'AI Partner Notifications';

  Future<void> initNotification() async {
    // 🔹 Android init
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 🔹 iOS init
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // 🔹 Combined init
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // ✅ FIX: use named parameter "settings"
    await _notificationsPlugin.initialize(settings: initializationSettings);

    // 🔹 Android specific setup (permissions + channel)
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();

      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.max,
          playSound: true,
        ),
      );
    }
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    // 🔹 Respect user settings
    if (!_settingsCubit.state.notificationsEnabled) return;

    try {
   await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      ); } catch (e) {
      debugPrint('Notification Error: $e');
    }
  }
}
