import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:todo_bloc/model/todo.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  // Ensure AwesomeNotifications is initialized in the background isolate
  await AwesomeNotifications().initialize('resource://mipmap/ic_launcher', [
    NotificationChannel(
      channelKey: 'high_priority_v4',
      channelName: 'High Priority',
      importance: NotificationImportance.Max,
      playSound: true,
      soundSource: 'resource://raw/high_priority',
      criticalAlerts: true,
      channelDescription: 'Critical todo alerts',
    ),
    NotificationChannel(
      channelKey: 'medium_priority_v4',
      channelName: 'Medium Priority',
      importance: NotificationImportance.Max,
      playSound: true,
      soundSource: 'resource://raw/medium_priority',
      criticalAlerts: true,
      channelDescription: 'Medium todo alerts',
    ),
    NotificationChannel(
      channelKey: 'low_priority_v4',
      channelName: 'Low Priority',
      importance: NotificationImportance.High,
      playSound: true,
      soundSource: 'resource://raw/low_priority',
      channelDescription: 'Low todo alerts',
    ),
  ]);

  print('🔔 Background message: ${message.messageId}');
  await FirebaseApi()._showAwesomeNotification(message);
}

class FirebaseApi {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Request permission for FCM
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    final token = await _messaging.getToken();
    print('📱 FCM Token: $token');

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground message: ${message.messageId}');
      _showAwesomeNotification(message);
    });

    // Handle when app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened app: ${message.data}');
    });
  }

  Future<void> _showAwesomeNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null && data.isEmpty) return;

    String title = notification?.title ?? data['title'] ?? 'New Notification';
    String body = notification?.body ?? data['body'] ?? '';
    String priorityStr = data['priority']?.toString().toLowerCase() ?? 'low';

    String channelKey = _getChannelKey(priorityStr);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: channelKey,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: Map<String, String>.from(data),
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: true,
        category: NotificationCategory.Message,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN',
          label: 'Open App',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  String _getChannelKey(String priorityStr) {
    Priority priority = _parsePriority(priorityStr);
    return _getChannelKeyForPriority(priority);
  }

  Priority _parsePriority(String? priorityString) {
    switch (priorityString?.toLowerCase()) {
      case 'critical':
        return Priority.critical;
      case 'high':
        return Priority.high;
      case 'medium':
        return Priority.medium;
      case 'low':
        return Priority.low;
      default:
        return Priority.low;
    }
  }

  String _getChannelKeyForPriority(Priority priority) {
    switch (priority) {
      case Priority.critical:
      case Priority.high:
        return 'high_priority_v4';
      case Priority.medium:
        return 'medium_priority_v4';
      case Priority.low:
        return 'low_priority_v4';
      default:
        return 'low_priority_v4';
    }
  }
}
