import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background message handler — MUST be a top-level function (not inside a class)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📬 Background notification: ${message.notification?.title}');
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android notification channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'itac_high_importance_channel',
    'ITAC Notifications',
    description: 'Push notifications for ITAC Admin App',
    importance: Importance.max,
  );

  /// Call this once in main() BEFORE runApp()
  static Future<void> initialize() async {
    // 1. Initialize Firebase
    await Firebase.initializeApp();

    // 2. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 3. Set up local notifications (needed to show heads-up on Android foreground)
    await _setupLocalNotifications();

    // 4. Request permission (iOS shows native dialog, Android 13+ also needs this)
    await _requestPermission();

    // 5. Get & print the device token (you'll use this to test)
    await _getToken();

    // 6. Listen to foreground messages
    _listenForeground();

    // 7. Handle notification tap when app is in background (but not terminated)
    _listenBackgroundTap();

    // 8. Handle notification tap when app was terminated
    await _handleTerminatedLaunch();

    // iOS foreground notification options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We request separately
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // User tapped a local notification
        print('🔔 Local notification tapped: ${response.payload}');
        _handleNotificationTap(response.payload);
      },
    );

    // Create the Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  static Future<void> _getToken() async {
    try {
      // APNs token required first on iOS
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        print('📱 APNs Token: $apnsToken');
      }

      final fcmToken = await _messaging.getToken();
      print('🔑 FCM Token: $fcmToken');
      // ↑ Copy this token from your console to send test notifications

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
        // TODO: send this new token to your backend if you store tokens
      });
    } catch (e) {
      print('❌ Token error: $e');
    }
  }

  // ── FOREGROUND ────────────────────────────────────────────────────────────
  // By default iOS doesn't show notifications when app is open.
  // We use flutter_local_notifications to manually show them.
  static void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground notification: ${message.notification?.title}');
      print('📨 Foreground notification received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      final notification = message.notification;
      if (notification == null) return;

      // Show as heads-up notification via local notifications
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['route'], // optional: for navigation on tap
      );
    });
  }

  // ── BACKGROUND TAP ────────────────────────────────────────────────────────
  // App was in background, user tapped the notification
  static void _listenBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          '👆 Notification tapped (background): ${message.notification?.title}');
      print('👆 Notification tapped');
      print(message.data);
      _handleNotificationTap(message.data['route']);
    });
  }

  // ── TERMINATED TAP ────────────────────────────────────────────────────────
  // App was closed, notification tapped → app launched
  static Future<void> _handleTerminatedLaunch() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      print('🚀 App launched via notification: ${message.notification?.title}');
      _handleNotificationTap(message.data['route']);
    }
  }

  // ── NAVIGATION ON TAP ─────────────────────────────────────────────────────
  // Add your navigation logic here based on the route in notification payload
  static void _handleNotificationTap(String? route) {
    if (route == null) return;
    print('🗺️ Navigate to: $route');
    // Example: navigate to a specific screen based on route key
    // You can use a GlobalKey<NavigatorState> here to navigate
    // e.g. navigatorKey.currentState?.pushNamed(route);
  }

  /// Manually get the current FCM token (call anytime to refresh/display)
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
