import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:uni_links/uni_links.dart';
import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';

class LedControlScreen extends StatefulWidget {
  @override
  _LedControlScreenState createState() => _LedControlScreenState();
}

class _LedControlScreenState extends State<LedControlScreen> {
  int doSangCuaDen = 0;
  String nutDoiMau = "";
  String nutNguon = "";
  String tuDongSang = "1";

  @override
  void initState() {
    super.initState();
    listenToLedControlChanges();
  }

  void listenToLedControlChanges() {
    DatabaseReference ref = FirebaseDatabase.instance.ref("LED_CONTROL");

    ref.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> data =
            Map<dynamic, dynamic>.from(snapshot.value as Map);
        setState(() {
          doSangCuaDen = (int.parse(data["doSangCuaDen"]) * 100 ~/ 255);
          // Chuyển từ 0-100 sang 0-255: A = (B * 255) / 100
          nutDoiMau = data["nutDoiMau"].toString();
          nutNguon = data["nutNguon"].toString();
          tuDongSang = data["tuDongSang"].toString();
        });
      } else {
        print('That bai');
      }
    });
  }

  StreamSubscription? _sub;

  Future<void> initUniLinks() async {
    _sub = linkStream.listen((String? link) async {
      if (link != null) {
        final uri = Uri.parse(link);
        final action = uri.queryParameters['action'];

        if (action != null) {
          if (action.toUpperCase() == 'ON') {
            updateNutNguon("ON"); // Bật đèn
          } else if (action.toUpperCase() == 'OFF') {
            updateNutNguon("OFF"); // Tắt đèn
          }
        }
      }
    }, onError: (err) {
      print("Lỗi: $err");
    });
  }

  void updateNutNguon(String newValue) {
    DatabaseReference ref = FirebaseDatabase.instance.ref("LED_CONTROL");

    ref.update(
      {
        "nutNguon": newValue,
      },
    ).then((_) {
      print("Cập nhật nutNguon thành công: $newValue");
    }).catchError((error) {
      print("Lỗi khi cập nhật: $error");
    });
  }

  // void updateNutNguon(String newValue) {
  //   DatabaseReference ref = FirebaseDatabase.instance.ref("LED_CONTROL");

  //   ref.update(
  //     {
  //       "nutNguon": newValue,
  //     },
  //   ).then((_) {
  //     print("Cập nhật nutNguon thành công");
  //   }).catchError((error) {
  //     print("Lỗi khi cập nhật: $error");
  //   });
  // }

  // @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("LED Control")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Độ sáng của đèn: $doSangCuaDen"),
            Text("Nút đổi màu: $nutDoiMau"),
            Text("Nút nguồn: $nutNguon"),
            Text("Tự động sáng: $tuDongSang"),
            ElevatedButton(
                onPressed: () => updateNutNguon("1"), child: Text('Bật đèn')),
          ],
        ),
      ),
    );
  }
}
