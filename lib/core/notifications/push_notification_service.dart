import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/notifications/data/notification_models.dart';
import '../../features/notifications/notification_navigation.dart';
import '../../firebase_options.dart';
import '../config/app_config.dart';
import '../auth/token_storage.dart';
import '../../features/notifications/data/notification_repository.dart';

class PushNotificationService {
  PushNotificationService(this._storage, this._repository);
  final TokenStorage _storage;
  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  void Function(String route)? onNavigate;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!AppConfig.enableFirebase) return;
    try {
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        } catch (_) {
          await Firebase.initializeApp();
        }
      }
    } catch (_) {
      return;
    }
    _initialized = true;
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
    if (!kIsWeb) {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      await _local.initialize(
        settings: const InitializationSettings(android: android, iOS: darwin),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.startsWith('/')) {
            onNavigate?.call(payload);
          }
        },
      );
    }
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = _routeFromData(message.data);
      if (route != null) onNavigate?.call(route);
    });
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      final route = _routeFromData(initial.data);
      if (route != null) {
        Future.microtask(() => onNavigate?.call(route));
      }
    }
    await _registerToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((_) => _registerToken());
    FirebaseMessaging.onMessage.listen(_foregroundMessage);
  }

  String? _routeFromData(Map<String, dynamic> data) {
    final item = AppNotification.fromJson({
      'id': data['notificationId']?.toString() ?? '',
      'type': data['type']?.toString() ?? 'GENERAL',
      'title': '',
      'message': '',
      'isRead': true,
      'createdAt': DateTime.now().toIso8601String(),
      'relatedEntityType': data['relatedEntityType'],
      'relatedEntityId': data['relatedEntityId'],
    });
    return notificationRoute(item);
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
    if (kIsWeb) return;
    final route = _routeFromData(message.data);
    const details = NotificationDetails(
      android: AndroidNotificationDetails('workforce_general', 'Work-Force notifications', importance: Importance.high, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
    await _local.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: route,
    );
  }
}
