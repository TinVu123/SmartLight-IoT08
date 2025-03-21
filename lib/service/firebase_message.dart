import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManger {
  // Tạo đối tượng FirebaseMessaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Yêu cầu quyền từ người dùng
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('Người dùng từ chối quyền thông báo');
      return;
    }

    // Lấy token FCM của thiết bị
    final fCMToken = await _firebaseMessaging.getToken();
    final ref =
        FirebaseDatabase.instance.ref('TIME_NOTIFICATION/tokens_device');
    // Lưu vào bộ nhớ để không đẩy fcm token lên firebase nhiều lần
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? checkfcm = prefs.getString('fcmtoken');
    if (checkfcm == null) {
      ref.push().set({'token': fCMToken});
      prefs.setString('fcmtoken', '$fCMToken');
    }
    print('FCM Token: $fCMToken');

    // Lắng nghe tin nhắn khi app đang mở (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Nhận được tin nhắn khi đang mở ứng dụng: ${message.notification?.title} - ${message.notification?.body}');
    });

    // Lắng nghe khi bấm vào thông báo từ trạng thái background hoặc terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'Người dùng đã bấm vào thông báo: ${message.notification?.title} - ${message.notification?.body}');
    });

    // Lắng nghe tin nhắn khi ứng dụng bị tắt và khởi động từ thông báo
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print(
          'Ứng dụng mở từ thông báo: ${initialMessage.notification?.title} - ${initialMessage.notification?.body}');
    }
    // initPushNotification();
  }

  // function to handle received messages
  // void handleMessage(RemoteMessage? message) {
  //   // if the message is null, do nothing
  //   if (message == null) return;
  //   // navigate to new screen when message is received and user tap notification
  //   navigatorKey.currentState?.pushNamed(
  //     '/notification_screen',
  //     arguments: message,
  //   );
  // }

  // Future initPushNotification() async {
  //   FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

  //   // attach envent listeners for when a notification opens the app
  //   FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  // }
}
