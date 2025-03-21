import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartlight/pages/home_page2.dart';
import 'package:smartlight/service/firebase_message.dart';
import 'firebase_options.dart';
import 'dart:async'; // Cung cấp StreamSubscription

// Hàm xử lý thông báo nền
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // // Đăng ký background handler
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await FirebaseMessaging.instance.requestPermission();
  // await NotificationManager().initNotifications();
  // initFirebase();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initFirebase();
  }

  void initFirebase() async {
    // Đăng ký background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    Future.delayed(Duration(seconds: 2), () async {
      await FirebaseMessaging.instance.requestPermission();
      await NotificationManager().initNotifications();
    });
  }

  StreamSubscription? _sub; // Biến lưu trữ đăng ký Stream

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
