import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sleeptracker/screens/welcome_screen.dart';
import 'package:sleeptracker/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  tz.initializeTimeZones(); // Initialisation des fuseaux horaires

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyCfQsKKvqd74UBfHS8FBlmOeZpHIIO_Zqk',
          appId: '1:880877991707:android:dc608d77456546f05f85be',
          messagingSenderId: '880877991707', projectId: '880877991707'),
  );



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WelcomeScreen(),
    );
  }
}


