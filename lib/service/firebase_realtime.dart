import 'package:firebase_database/firebase_database.dart';

class FirebaseManager {
  // Biến static để lưu instance duy nhất
  static final FirebaseManager _instance = FirebaseManager._internal();

  // Factory constructor để trả về instance duy nhất
  factory FirebaseManager() {
    return _instance;
  }

  // Với cách thiết kế Singleton trong FirebaseManager, instance duy nhất sẽ tự động
  // được tạo ngay lần đầu tiên bạn gọi FirebaseManager() trong ứng dụng.

  // Constructor riêng tư
  FirebaseManager._internal();

  final DatabaseReference _ref = FirebaseDatabase.instance.ref("LED_CONTROL");

  // Hàm lắng nghe thay đổi từ Firebase
  void listenToLedControlChanges({
    required Function(double doSangCuaDen, String nutDoiMau, String nutNguon,
            String tuDongSang)
        onDataChanged,
    Function? onError,
  }) {
    _ref.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> data =
            Map<dynamic, dynamic>.from(snapshot.value as Map);
        double doSangCuaDen = (double.parse(data["doSangCuaDen"]) * 100 / 255);
        String nutDoiMau = data["nutDoiMau"].toString();
        String nutNguon = data["nutNguon"].toString();
        String tuDongSang = data["nutTuDongSang"].toString();

        onDataChanged(doSangCuaDen, nutDoiMau, nutNguon, tuDongSang);
      } else {
        print('Không có dữ liệu');
        if (onError != null) onError();
      }
    });
  }

  // Hàm cập nhật giá trị
  void updateField(String field, String newValue) {
    _ref.update({
      field: newValue,
    }).then((_) {
      print("Cập nhật $field thành công: $newValue");
    }).catchError((error) {
      print("Lỗi khi cập nhật: $error");
    });
  }
}
