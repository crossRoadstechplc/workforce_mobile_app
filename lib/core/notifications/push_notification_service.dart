import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/notifications/data/notification_repository.dart';
import '../config/app_config.dart';
import '../auth/token_storage.dart';

class PushNotificationService {
  PushNotificationService(this._storage, this._repository);
  final TokenStorage _storage;
  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!AppConfig.enableFirebase) return;
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    } catch (_) {
      return;
    }
    _initialized = true;
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );
    await _registerToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((_) => _registerToken());
    FirebaseMessaging.onMessage.listen(_foregroundMessage);
  }

  Future<void> _registerToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    final deviceId = await _storage.readOrCreateDeviceId();
    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'IOS',
      TargetPlatform.android => 'ANDROID',
      _ => 'WEB',
    };
    await _repository.registerDevice(deviceId: deviceId, fcmToken: token, platform: platform).catchError((_) {});
  }

  Future<void> unregister() async {
    if (!_initialized) return;
    final deviceId = await _storage.readOrCreateDeviceId();
    await _repository.removeDevice(deviceId).catchError((_) {});
  }

  Future<void> _foregroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails('workforce_general', 'Workforce notifications', importance: Importance.high, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
    await _local.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
    );
  }
}
