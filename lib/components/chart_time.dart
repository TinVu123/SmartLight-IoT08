import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChartTime extends StatefulWidget {
  const ChartTime({super.key});

  @override
  State<ChartTime> createState() => _ChartTimeState();
}

class _ChartTimeState extends State<ChartTime> {
  List<int> lightInten = [];
  @override
  void initState() {
    super.initState();
    getTimeUseData();
    getLightInten();
  }

  Future<List<int>> getLightInten() async {
    DatabaseReference refLight =
        FirebaseDatabase.instance.ref('LIGHT_INTENSITY');
    final snapshot = await refLight.get();

    if (snapshot.exists) {
      Map<String, dynamic> data =
          Map<String, dynamic>.from(snapshot.value as Map);
      Map<String, int> tempResult = {};

      // Lấy dữ liệu và chuyển sang Map
      for (var entry in data.entries) {
        String key = entry.key;
        dynamic rawValue = entry.value;

        if (rawValue is int) {
          tempResult[key] = rawValue;
        } else {
          print("Giá trị không phải int: $rawValue");
        }
      }

      // Sắp xếp theo ngày tăng dần
      var sortedEntries = tempResult.entries.toList()
        ..sort(
            (b, a) => DateTime.parse(a.key).compareTo(DateTime.parse(b.key)));

      // Chuyển values thành List<int>
      lightInten = sortedEntries.map((entry) => entry.value).toList();
      // lightInten.reversed;

      return lightInten;
    } else {
      print("No data exists in TIME_USE.");
      return []; // Trả về list rỗng thay vì {}
    }
  }

  Future<Map<String, int>> getTimeUseData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('TIME_USE');
    final snapshot = await ref.get();

    Map<String, int> tempResult = {};

    if (snapshot.exists) {
      Map<String, dynamic> data =
          Map<String, dynamic>.from(snapshot.value as Map);

      for (var entry in data.entries) {
        String key = entry.key;
        dynamic rawValue = entry.value;

        if (rawValue is int) {
          tempResult[key] = rawValue;
        } else {
          print("Giá trị không phải int: $rawValue");
        }
      }

      // Sắp xếp theo ngày tăng dần
      var sortedEntries = tempResult.entries.toList()
        ..sort(
            (a, b) => DateTime.parse(b.key).compareTo(DateTime.parse(a.key)));

      Map<String, int> sortedMap = Map.fromEntries(sortedEntries);
      return sortedMap;
    } else {
      print("No data exists in TIME_USE.");
      return {};
    }
  }

  List<BarChartGroupData> generateBarData(
      List<MapEntry<String, int>> entries, int maxMinutes, int startIndex) {
    List<BarChartGroupData> barGroups = [];

    // Chỉ lấy 7 cột cho mỗi page
    for (int i = 0; i < 5 && (startIndex + i) < entries.length; i++) {
      double timeUsed = entries[startIndex + i].value.toDouble();
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: timeUsed,
              color: Colors.lightBlue,
              width: 15,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            BarChartRodData(
              toY: lightInten[startIndex + i].toDouble(),
              color: Colors.amber,
              width: 15,
            ),
          ],
        ),
      );
    }
    // return barGroups;
    return barGroups.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future:
          getTimeUseData(), // Mỗi khi rebuild thì lại gọi lại ---> tốn thời gian nên đưa vào initState để chỉ gọi 1 lần
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center();
        } else if (snapshot.hasError) {
          return const Center(child: Text("Lỗi khi tải dữ liệu"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có dữ liệu"));
        }

        Map<String, int> timeUseData = snapshot.data!;
        int maxTime = timeUseData.values.reduce((a, b) => a > b ? a : b);
        List<MapEntry<String, int>> entries = timeUseData.entries.toList();

        // Tính số lượng page (mỗi page 7 ngày)
        int pageCount = (entries.length / 5).ceil();

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: Card(
              elevation: 3,
              color: Colors.white,
              child: Container(
                height: 300,
                width: double.infinity,
                padding: EdgeInsets.only(top: 0, bottom: 15),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Time use:',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                height: 20,
                                width: 20,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Light intensity:',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                height: 20,
                                width: 20,
                                color: Colors.amber,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6.0, right: 6),
                        child: PageView.builder(
                          reverse: true,
                          itemCount: pageCount,
                          itemBuilder: (context, pageIndex) {
                            int startIndex = pageIndex * 5;
                            return SizedBox(
                              width: 5 * 56.0, // Chiều rộng cho 7 cột
                              child: BarChart(
                                BarChartData(
                                  barGroups: generateBarData(
                                      entries, maxTime, startIndex),
                                  maxY: maxTime + 100,
                                  minY: 0,
                                  titlesData: FlTitlesData(
                                    show: true,
                                    topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 125,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )),
                                    // leftTitles: AxisTitles(
                                    //     sideTitles: SideTitles(
                                    //   maxIncluded: 100.0,
                                    //   showTitles: true,
                                    // )),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,

                                        interval:
                                            20, // mỗi 20 đơn vị hiển thị 1 nhãn
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                          // Tùy chỉnh nội dung nhãn dựa vào 'value'
                                          String text;
                                          if (value % 60 == 0 &&
                                              value >= 0 &&
                                              value <= 1440) {
                                            int hour = value ~/
                                                60; // Chia nguyên phút thành giờ
                                            text = '${hour}h';
                                          } else {
                                            return Container(); // Không hiển thị nếu không đúng phút tròn giờ
                                          }

                                          return Text(
                                            text,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          int index =
                                              startIndex + value.toInt();
                                          if (index >= 0 &&
                                              index < entries.length) {
                                            String dateStr = entries[index].key;
                                            DateTime date =
                                                DateTime.parse(dateStr);
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0),
                                              child: Text(
                                                "${date.day}/${date.month}",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text("");
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(
                                    show: true,
                                    drawHorizontalLine: true, // Lưới ngang
                                    drawVerticalLine: false,
                                    horizontalInterval: 60,

                                    // dọc
                                  ),
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      // tooltipBgColor: Colors.black.withOpacity(0.7),
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        final value = rod
                                            .toY; // Giá trị cột được chạm vào
                                        String value2 = '';
                                        if (rodIndex == 0) {
                                          int v1 = rod.toY ~/ 60; // số giờ
                                          int v2 =
                                              rod.toY.toInt() % 60; // số phút

                                          if (v1 != 0) {
                                            value2 = v1.toString() +
                                                'h' +
                                                v2.toString() +
                                                '\'';
                                          } else {
                                            value2 = v2.toString() + '\'';
                                          }
                                        } else {
                                          value2 = rod.toY.toInt().toString();
                                        }

                                        // }
                                        return BarTooltipItem(
                                          // 'Giá trị: ${v1.toString()} , ${v2.toString()}',
                                          value2,
                                          TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
