import 'dart:io';
import "package:awesome_notifications/awesome_notifications.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_bloc/api/firebase_api.dart';
import 'package:todo_bloc/bloc/todo_bloc.dart';
import 'package:todo_bloc/event/todo_event.dart';
import 'package:todo_bloc/firebase_options.dart';
import 'package:todo_bloc/services/notification_controller.dart';
import "package:todo_bloc/ui/welcome/welcome_view.dart";
import 'dart:typed_data';

final Int64List highVibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      if (Platform.isAndroid) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    }

    await AwesomeNotifications().initialize(
      'resource://mipmap/ic_launcher',
      [
        NotificationChannel(
          channelKey: 'high_priority_v4',
          channelName: 'High Priority',
          channelDescription: 'Critical todo alerts',
          importance: NotificationImportance.Max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: highVibrationPattern,
          criticalAlerts: true,
          soundSource: 'resource://raw/high_priority',
          defaultRingtoneType: DefaultRingtoneType.Notification,
          ledColor: Colors.red,
          defaultColor: const Color(0xFF6366F1),
        ),
        NotificationChannel(
          channelKey: 'medium_priority_v4',
          channelName: 'Medium Priority',
          channelDescription: 'Medium todo alerts',
          importance: NotificationImportance.Max,
          playSound: true,
          enableVibration: true,
          criticalAlerts: true,
          soundSource: 'resource://raw/medium_priority',
          defaultRingtoneType: DefaultRingtoneType.Notification,
          ledColor: Colors.orange,
          defaultColor: const Color(0xFF6366F1),
        ),
        NotificationChannel(
          channelKey: 'low_priority_v4',
          channelName: 'Low Priority',
          channelDescription: 'Low todo alerts',
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
          soundSource: 'resource://raw/low_priority',
          defaultRingtoneType: DefaultRingtoneType.Notification,
          ledColor: Colors.blue,
          defaultColor: const Color(0xFF6366F1),
        ),
      ],
      debug: true,
    );

    // Set listeners
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    );

    // Request permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications(
          permissions: [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Badge,
            NotificationPermission.Vibration,
            NotificationPermission.Light,
            NotificationPermission.PreciseAlarms,
          ],
        );
      } else {
        // If already allowed, check for precise alarms specifically
        List<NotificationPermission> lockedPermissions = await AwesomeNotifications().shouldShowRationaleToRequest();
        if (lockedPermissions.contains(NotificationPermission.PreciseAlarms)) {
          await AwesomeNotifications().requestPermissionToSendNotifications(
            permissions: [NotificationPermission.PreciseAlarms],
          );
        }
      }
    });

    await FirebaseApi().initNotifications();
  } catch (e) {
    debugPrint('Startup error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) {
          final todoBloc = TodoBloc();
          todoBloc.add(LoadTodosEvent());
          return todoBloc;
        },
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "KARYA",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFFA855F7),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          color: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const WelcomeView(),
    ),
  );
}
