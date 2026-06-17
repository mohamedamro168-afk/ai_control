import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz2;

import 'screens/onboarding/welcome_screen.dart';

final FlutterLocalNotificationsPlugin notifications =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة المناطق الزمنية
  tz.initializeTimeZones();

  // ضبط المنطقة الزمنية لمصر
  tz2.setLocalLocation(
    tz2.getLocation('Africa/Cairo'),
  );

  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
  InitializationSettings(
    android: androidSettings,
  );

  await notifications.initialize(settings);

  final androidPlugin =
  notifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.requestNotificationsPermission();
  await androidPlugin?.requestExactAlarmsPermission();

  runApp(const AiControlApp());
}

class AiControlApp extends StatelessWidget {
  const AiControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0a0a0f),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7c6ef7),
          surface: Color(0xFF0a0a0f),
        ),
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}