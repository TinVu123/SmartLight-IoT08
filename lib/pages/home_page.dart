import 'package:firebase_database/firebase_database.dart';
import 'package:smartlight/components/cards.dart';
import 'package:smartlight/components/cart_notification.dart';
import 'package:smartlight/components/chart_time.dart';
import 'package:smartlight/components/pick_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  }

  DatabaseReference ref = FirebaseDatabase.instance.ref("LED_CONTROL");

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
        body: StreamBuilder<DatabaseEvent>(
          stream: ref.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Đã xảy ra lỗi!'));
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text('Không có dữ liệu!'));
            }
            Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                snapshot.data!.snapshot.value as Map);
            buttonLight = data['nutNguon'] == '1' ? true : false;
            buttonBrightAuto = data['nutTuDongSang'] == '1' ? true : false;

            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  children: [
                    const ChartTime(),

                    const SizedBox(height: 15),

                    // Slider độ sáng để quan sát hoặc điều chỉnh độ sáng
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 10),
                      child: Card(
                        elevation: 3,
                        child: Container(
                          width: double.infinity,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const MySlider(),
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
                    const Card_Notification(),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
