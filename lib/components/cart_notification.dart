import 'package:firebase_database/firebase_database.dart';
import 'package:smartlight/components/switch_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Card_Notification extends StatefulWidget {
  const Card_Notification({super.key});

  @override
  State<Card_Notification> createState() => _NotificationnState();
}

class _NotificationnState extends State<Card_Notification> {
  final DatabaseReference ref =
      FirebaseDatabase.instance.ref('TIME_NOTIFICATION');

  void updateTimeNotification(String newValue) {
    ref.update({'time_notification': newValue}).catchError((error) {
      print("Lỗi khi cập nhật: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: ref.onValue, // Lắng nghe sự thay đổi dữ liệu thời gian thực
      builder: (context, snapshot) {
        // Kiểm tra trạng thái kết nối và dữ liệu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Đã xảy ra lỗi!'));
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text('Không có dữ liệu!'));
        }

        // Lấy dữ liệu từ snapshot
        Map<dynamic, dynamic> data =
            Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
        String time = data['time_notification'].toString();
        String isOn = data['state_notification'].toString();

        // In dữ liệu ra console để debug
        print('Thời gian: $time');
        print('Trạng thái: $isOn');

        // Giao diện chính
        return Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ListTile(
              leading: GestureDetector(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (BuildContext context, Widget? child) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: child!,
                      );
                    },
                  );

                  if (pickedTime != null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Thời gian đã chọn"),
                        content:
                            Text("Bạn đã chọn: ${pickedTime.format(context)}"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              updateTimeNotification(
                                  pickedTime.format(context));
                              // Không cần gọi listenToTimeNotification() vì StreamBuilder tự động cập nhật
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              title: Text(
                'Nhắc nhở',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(fontSize: 20),
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text('Time: $time'),
              trailing: MySwitchButton(
                state: isOn == '1' ? true : false,
                type: 'notification',
              ),
            ),
          ),
        );
      },
    );
  }
}
