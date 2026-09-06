import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';

/// Handles FCM + local notifications (mobile).
/// On web, FCM is skipped until a proper service worker is added.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'efoot_arena_channel',
    'eFoot Arena',
    description: 'Notifications défis, équipes et classements',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    // Web needs firebase-messaging-sw.js + correct MIME type.
    // Skip entirely so the app does not crash with a white screen.
    if (kIsWeb) {
      debugPrint('NotificationService: skipped on web (no service worker).');
      _initialized = true;
      return;
    }

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _initialized = true;
        return;
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      await _local.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );

      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        _handleMessageNavigation(initial);
      }

      await _saveToken();
      _messaging.onTokenRefresh.listen((token) => _saveToken(token: token));
    } catch (e, st) {
      debugPrint('NotificationService initialize error: $e\n$st');
    }

    _initialized = true;
  }

  Future<void> _saveToken({String? token}) async {
    if (kIsWeb) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final fcmToken = token ?? await _messaging.getToken();
      if (fcmToken == null) return;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(
        {
          'fcmToken': fcmToken,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('FCM token save failed: $e');
    }
  }

  Future<void> syncTokenForCurrentUser() async {
    if (kIsWeb) return;
    await _saveToken();
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (_) {}
  }

  void _handleMessageNavigation(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final route = data['route'] as String?;
    onNotificationTap?.call(type: type, route: route, data: data);
  }

  static void Function({
    String? type,
    String? route,
    Map<String, dynamic>? data,
  })? onNotificationTap;

  Future<void> clearTokenOnLogout() async {
    if (kIsWeb) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'fcmToken': FieldValue.delete()});
    } catch (_) {}
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Keep light — heavy work belongs in Cloud Functions
}
