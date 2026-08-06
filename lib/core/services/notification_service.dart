import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;
// CHANGED: removed `import 'dart:io';` — Platform.isAndroid from dart:io crashes on Flutter Web.
// Replaced with kIsWeb/defaultTargetPlatform from Flutter itself, which work everywhere including web.
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Request Permission (iOS/Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('NOTIFICATION_LOG: User granted permission');
    }

    // 2. Initialize Local Notifications (for Foreground messages)
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click when app is in foreground
        print('NOTIFICATION_LOG: Foreground notification clicked: ${details.payload}');
      },
    );

    // 3. Create Android Channel (Required for high importance)
    // CHANGED: was `if (Platform.isAndroid)` — that line alone was throwing on web
    // (Platform class doesn't exist in a browser), which silently killed the whole
    // initialize() call since main.dart wraps this in a try/catch.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'robox_finance_channel',
        'Financial Alerts',
        description: 'Notifications for new income and expenses.',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 4. Listen for Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('NOTIFICATION_LOG: Message received in foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 5. Handle Background/Terminated Click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('NOTIFICATION_LOG: App opened from notification: ${message.data}');
    });

    _initialized = true;
  }

  Future<String?> getToken() async {
    try {
      // CHANGED: was `String? token = await _fcm.getToken();` — web requires an
      // explicit VAPID key to be passed in, or getToken() fails on web specifically.
      // PASTE YOUR ACTUAL KEY BELOW, replacing the placeholder text:
      String? token = kIsWeb
          ? await _fcm.getToken(vapidKey: 'BGUhAysyuFVzC6s5rAeeLVJN2OefZ-h4It-gOjhhh49h8ym-l1l1SkBjSXAqc2dOcbN6rC2I1cWPj1KRfmFs8J8') // <-- put your real key here
          : await _fcm.getToken();
      print('NOTIFICATION_LOG: Device Token: $token');
      return token;
    } catch (e) {
      print('NOTIFICATION_LOG: Error getting token: $e');
      return null;
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    // Note: the unused `android` variable from your original was removed here —
    // it was declared but never actually used anywhere below, harmless either way.

    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'robox_finance_channel',
            'Financial Alerts',
            channelDescription: 'Notifications for new income and expenses.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }
}