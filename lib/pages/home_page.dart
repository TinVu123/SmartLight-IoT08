import 'package:smartlight/components/cards.dart';
import 'package:smartlight/components/chart_time.dart';
import 'package:smartlight/components/pick_color.dart';
import 'package:smartlight/components/switch_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartlight/service/firebase_realtime.dart';
import '../components/brightness.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool buttonLight = true;
  late bool buttonBrightAuto = false;

  @override
  void initState() {
    super.initState();
    FirebaseManager().listenToLedControlChanges(
      onDataChanged: (doSangCuaDen, nutDoiMau, nutNguon, tuDongSang) {
        if (mounted) {
          setState(() {
            buttonLight = nutNguon == '1' ? true : false;
            buttonBrightAuto = tuDongSang == '1' ? true : false;
          });
        }
      },
      onError: () {
        print('Lỗi khi lắng nghe dữ liệu');
      },
    );
  }

  // Lấy dữ liệu chỉ 1 lần khi mở ứng dụng
  // Future<void> fetchInitialData() async {
  //   DatabaseReference ref = FirebaseDatabase.instance.ref("LED_CONTROL");
  //   DataSnapshot snapshot = await ref.get();
  //   if (snapshot.value != null) {
  //     Map<dynamic, dynamic> data =
  //         Map<dynamic, dynamic>.from(snapshot.value as Map);
  //     int nutNguon = int.tryParse(data["nutNguon"].toString()) ?? 0;
  //     int tuDongSang = int.tryParse(data["tuDongSang"].toString()) ?? 0;

  //     setState(() {
  //       buttonLight = nutNguon == 1;
  //       buttonBrightAuto = tuDongSang == 1;
  //     });
  //   }
  // }

  double currentv = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'My light',
              style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.black87)),
            ),
          ],
        ),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications),
            color: Colors.black87,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              const ChartTime(),

              const SizedBox(height: 15),

              // Slider độ sáng để quan sát hoặc điều chỉnh độ sáng
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
                child: Card(
                  elevation: 3,
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MySlider(),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // On/Off light
              CustomCard(
                  title: 'Light',
                  color: Colors.orange,
                  iconData: Icons.lightbulb,
                  buttonFunction: 'light',
                  buttonState: buttonLight),

              // Độ sáng thích ứng
              CustomCard(
                  title: "Brightness Auto",
                  color: Colors.lightGreen,
                  iconData: Icons.sunny,
                  buttonFunction: 'brightness',
                  buttonState: buttonBrightAuto),

              // Chọn màu đèn
              const PickerColor(),

              // Nhắc nhở
              Card(
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
                              content: Text(
                                  "Bạn đã chọn: ${pickedTime.format(context)}"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        // height: 85,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    title: Text(
                      'Nhắc nhở',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(fontSize: 22),
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text('Time: 7:00 PM'),
                    trailing: MySwitchButton(
                      state: true,
                      type: 'notification',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
