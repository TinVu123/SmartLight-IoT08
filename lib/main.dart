import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smartlight/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartlight/pages/home_page2.dart';
import 'package:smartlight/service/firebase_message.dart';
import 'firebase_options.dart';
import 'dart:async'; // Cung cấp StreamSubscription

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.instance.requestPermission(provisional: true);
  await NotificationManger().initNotifications();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub; // Biến lưu trữ đăng ký Stream

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel(); // Hủy đăng ký khi widget bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage2(),
      theme: ThemeData(scaffoldBackgroundColor: Colors.grey[300]),
    );
  }
}
