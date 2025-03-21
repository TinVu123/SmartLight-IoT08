import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Hàm xử lý thông báo nền
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationManager {
  // Tạo đối tượng FirebaseMessaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Tạo đối tượng FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Cấu hình kênh thông báo cho Android
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel', // ID kênh
    'High Importance Notifications', // Tên kênh
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  Future<void> initNotifications() async {
    // Yêu cầu quyền từ người dùng
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Kiểm tra trạng thái quyền
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // Khởi tạo local notifications
    await _initLocalNotifications();

    // Lấy token FCM của thiết bị
    _initializeFCMInBackground();

    // Đăng ký xử lý thông báo nền
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Lắng nghe tin nhắn khi app đang mở (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message); // Hiển thị thông báo trong foreground
      }
    });

    // Lắng nghe khi bấm vào thông báo từ trạng thái background hoặc terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Lắng nghe tin nhắn khi ứng dụng bị tắt và khởi động từ thông báo
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _showLocalNotification(initialMessage);
    }
  }

  Future<void> _initializeFCMInBackground() async {
    final fcmToken = await _firebaseMessaging.getToken();
    // print('FCM Token: $fcmToken');
    // Đẩy token lên Firebase ở đây nếu cần, nhưng không chặn UI
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      final ref =
          FirebaseDatabase.instance.ref('TIME_NOTIFICATION/tokens_device');
      ref.push().set({'token': fcmToken});
    });
  }

  // Khởi tạo local notifications
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initializationSettings);

    // Tạo kênh thông báo cho Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  // Hiển thị thông báo cục bộ
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode, // ID thông báo
      notification.title, // Tiêu đề
      notification.body, // Nội dung
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

// Gọi trong main.dart
