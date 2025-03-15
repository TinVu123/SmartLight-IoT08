import 'package:smartlight/components/my_switch_button.dart';
// import 'my_switch_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/brightness2.dart';
import '../components/chart_study.dart';
import '../components/number.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10),
                child: Container(
                  height: 310,
                  child: PageView(children: [
                    Container(
                      height: 310,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: BarChartSample1(),
                    ),
                    Container(
                      height: 200,
                      color: Colors.grey[200],
                    ),
                  ]),
                ),
              ),
              SizedBox(
                height: 15,
              ),

              // firebasetest(),

              SizedBox(
                height: 30,
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // Màu của bóng
                        spreadRadius: 1, // Độ lan của bóng
                        blurRadius: 5, // Độ mờ của bóng
                        offset: Offset(5, 5), // Độ dịch chuyển (X, Y)
                      ),
                    ],
                  ),
                  child: MySlider(),
                ),
              ),

              SizedBox(
                height: 30,
              ),

              // On/Off light
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: EdgeInsets.all(14),
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.lightbulb,
                                color: Colors.white,
                                size: 30,
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Light',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(fontSize: 24),
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      MySwitchButton(
                        type: 'light',
                      ),
                    ],
                  ),
                ),
              ),

              // Độ sáng của đèn
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: EdgeInsets.all(14),
                  height: 85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.sunny,
                                color: Colors.white,
                                size: 30,
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Độ sáng thích ứng',
                            style: GoogleFonts.roboto(
                                textStyle: TextStyle(fontSize: 22),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ],
                      ),

                      MySwitchButton(
                        type: 'brightness',
                      ),
                      // Expanded(child: MySlider()),
                    ],
                  ),
                ),
              ),

              // Promodo
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: EdgeInsets.all(14),
                  height: 85,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              // title: const Text("Chọn thời gian làm việc"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Học',
                                        style: GoogleFonts.roboto(
                                          textStyle: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60,
                                      ),
                                      Text(
                                        'Nghỉ',
                                        style: GoogleFonts.roboto(
                                          textStyle: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      PromodeTime(),
                                      PromodeTime(),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context), // Đóng dialog
                                  child: const Text(
                                    "Hủy",
                                    style: TextStyle(
                                        color: Colors.black87, fontSize: 20),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context), // Đóng dialog
                                  child: const Text(
                                    "Ok",
                                    style: TextStyle(
                                        color: Colors.black87, fontSize: 20),
                                  ),
                                ),
                                // ElevatedButton(
                                //   onPressed: () {
                                //     setState(() {
                                //       _selectedMinutes = tempValue;
                                //     });
                                //     Navigator.pop(context);
                                //   },
                                //   child: const Text("Xác nhận"),
                                // ),
                              ],
                            );
                          },
                        ),
                        child: Row(
                          children: [
                            Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purpleAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.restart_alt,
                                  color: Colors.white,
                                  size: 30,
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Promodo',
                                  style: GoogleFonts.roboto(
                                      textStyle: TextStyle(fontSize: 22),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Học: ',
                                      style: GoogleFonts.roboto(
                                          textStyle: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87)),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Nghỉ: ',
                                      style: GoogleFonts.roboto(
                                          textStyle: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      MySwitchButton(
                        type: 'promodo',
                      ),
                    ],
                  ),
                ),
              ),

              // Đặt lịch nhắc nhở
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: EdgeInsets.all(14),
                  height: 85,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
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
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: 30,
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nhắc nhở',
                                    style: GoogleFonts.roboto(
                                        textStyle: TextStyle(fontSize: 24),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Time:} ',
                                        style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          )),
                      MySwitchButton(
                        type: 'notification',
                      ),
                    ],
                  ),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.only(bottom: 8.0),
              //
              //   child: Brigthness(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
