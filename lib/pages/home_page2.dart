import 'package:firebase_database/firebase_database.dart';
import 'package:smartlight/components/cards.dart';
import 'package:smartlight/components/cart_notification.dart';
import 'package:smartlight/components/chart_time.dart';
import 'package:smartlight/components/pick_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/brightness.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage2> {
  bool buttonLight = true;
  bool buttonBrightAuto = false;
  late final DatabaseReference _ref;
  late final Stream<DatabaseEvent> _stream;
  List<int> lightInten = []; // Khởi tạo mặc định
  Map<String, int> timeUse = {}; // Khởi tạo mặc định

  Future<void> getLightInten() async {
    try {
      DatabaseReference refLight =
          FirebaseDatabase.instance.ref('LIGHT_INTENSITY');
      final snapshot = await refLight.get();
      if (snapshot.exists && snapshot.value is List) {
        setState(() {
          lightInten = List<int>.from(snapshot.value as List);
        });
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu LIGHT_INTENSITY: $e");
    }
  }

  Future<void> getTimeUseData() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref('TIME_USE');
      final snapshot = await ref.get();
      if (snapshot.value != null && snapshot.value is Map) {
        setState(() {
          timeUse = Map<String, int>.from(snapshot.value as Map);
        });
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu TIME_USE: $e");
    }
  }

  Future<void> initializeData() async {
    await getLightInten();
    await getTimeUseData();
    print('Light Intensity: $lightInten');
    print('Time Use: $timeUse');
  }

  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance.ref("LED_CONTROL");
    _stream = _ref.onValue;
    initializeData();
  }

  Widget _buildContent(Map<dynamic, dynamic> data) {
    buttonLight = data['nutNguon'] == '1';
    buttonBrightAuto = data['nutTuDongSang'] == '1';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Column(
          children: [
            ChartTime(
              lightInten: lightInten,
              timeUseData: timeUse,
            ),
            const SizedBox(height: 15),
            _buildBrightnessSlider(),
            const SizedBox(height: 5),
            CustomCard(
              title: 'Light',
              color: Colors.orange,
              iconData: Icons.lightbulb,
              buttonFunction: 'light',
              buttonState: buttonLight,
            ),
            CustomCard(
              title: "Brightness Auto",
              color: Colors.lightGreen,
              iconData: Icons.sunny,
              buttonFunction: 'brightness',
              buttonState: buttonBrightAuto,
            ),
            const PickerColor(),
            const Card_Notification(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrightnessSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' My light',
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: Colors.black87,
            ),
          ),
        ),
        backgroundColor: Colors.grey[300],
        actions: const [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.notifications, color: Colors.black87),
          )
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi!'));
          }
          final dynamic snapshotValue = snapshot.data?.snapshot.value;
          if (snapshotValue == null) {
            return const Center(child: Text('Không có dữ liệu!'));
          }
          return _buildContent(
              Map<dynamic, dynamic>.from(snapshotValue as Map));
        },
      ),
    );
  }
}
