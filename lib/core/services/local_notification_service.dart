import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;

  final StreamController<String> _orderTapController =
      StreamController<String>.broadcast();

  Stream<String> get orderTapStream => _orderTapController.stream;

  static const AndroidNotificationChannel orderChannel =
      AndroidNotificationChannel(
        'techshop_orders',
        'Order Notifications',
        description: 'Notifications about your TechShop orders',
        importance: Importance.high,
      );

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final orderId = response.payload;

        if (orderId != null && orderId.isNotEmpty) {
          _orderTapController.add(orderId);
        }
      },
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(orderChannel);
  }

  Future<AuthorizationStatus> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    return settings.authorizationStatus;
  }

  void listenToForegroundMessages() {
    _foregroundSubscription?.cancel();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      showNotification,
    );
  }

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;

    final title =
        notification?.title ?? message.data['title']?.toString() ?? 'TechShop';

    final body =
        notification?.body ??
        message.data['body']?.toString() ??
        'You have a new notification.';

    const androidDetails = AndroidNotificationDetails(
      'techshop_orders',
      'Order Notifications',
      channelDescription: 'Notifications about your TechShop orders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final notificationId =
        message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _notifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: message.data['order_id']?.toString(),
    );
  }

  /// Handles notification taps when the app was in the background.
  void listenToNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleRemoteMessageTap(message);
    });
  }

  /// Handles notification taps that launched the terminated app.
  Future<void> handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      _handleRemoteMessageTap(message);
    }
  }

  void _handleRemoteMessageTap(RemoteMessage message) {
    final orderId = message.data['order_id']?.toString();

    if (orderId != null && orderId.isNotEmpty) {
      _orderTapController.add(orderId);
    }
  }
}
