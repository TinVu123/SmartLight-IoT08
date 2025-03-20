import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LedControlScreen extends StatefulWidget {
  @override
  _LedControlScreenState createState() => _LedControlScreenState();
}

class _LedControlScreenState extends State<LedControlScreen> {
  int doSangCuaDen = 0;
  String nutDoiMau = "";
  String nutNguon = "";
  String tuDongSang = "1";
  String timeUse = "";

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

  void listenToLedTime() {
    DatabaseReference ref = FirebaseDatabase.instance.ref("TIME_USE/");

    ref.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> data =
            Map<dynamic, dynamic>.from(snapshot.value as Map);
        setState(() {
          timeUse = data["timeUse"].toString();
        });
      } else {
        print('That bai');
      }
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
            Text("Thời gian dùng: $timeUse"),
            ElevatedButton(
                onPressed: () => updateNutNguon("0"), child: Text('Bật đèn')),
          ],
        ),
      ),
    );
  }
}
