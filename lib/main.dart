// import 'package:denhoc/pages/chart_light.dart';
import 'package:smartlight/pages/home_page.dart';
// import 'package:denhoc/pages/led_control.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// import 'package:uni_links/uni_links.dart';
import 'dart:async'; // Cung cấp StreamSubscription
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    // initUniLinks();
  }

  // Future<void> initUniLinks() async {
  //   // Đăng ký lắng nghe deep link từ uni_links
  //   _sub = linkStream.listen((String? link) async {
  //     if (link != null) {
  //       final uri = Uri.parse(link);
  //       final action = uri.queryParameters['action'];
  //       if (action != null) {
  //         if (action.toUpperCase() == 'ON') {
  //           updateNutNguon("ON");
  //         } else if (action.toUpperCase() == 'OFF') {
  //           updateNutNguon("OFF");
  //         }
  //       }
  //     }
  //   }, onError: (err) {
  //     print("Lỗi: $err");
  //   });
  // }

  void updateNutNguon(String newValue) {
    DatabaseReference ref = FirebaseDatabase.instance.ref("LED_CONTROL");
    ref.update({"nutNguon": newValue}).then((_) {
      print("Cập nhật nutNguon thành công: $newValue");
    }).catchError((error) {
      print("Lỗi khi cập nhật: $error");
    });
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
      home: HomePage(),
      theme: new ThemeData(scaffoldBackgroundColor: Colors.grey[300]),
      // routes: {
      //   '/chart_light': (context) => ChartLight(),
      // },
    );
  }
}
