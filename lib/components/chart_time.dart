import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChartTime extends StatefulWidget {
  const ChartTime({super.key});

  @override
  State<ChartTime> createState() => _ChartTimeState();
}

class _ChartTimeState extends State<ChartTime> {
  @override
  void initState() {
    super.initState();
    getTimeUseData();
  }

  Future<Map<String, int>> getTimeUseData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('TIME_USE');

    print('Get data');
    Map<String, int> tempResult = {};

    final snapshot = await ref.get();

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
    for (int i = 0; i < 6 && (startIndex + i) < entries.length; i++) {
      double timeUsed = entries[startIndex + i].value.toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: timeUsed,
              color: Colors.lightBlue,
              width: 20,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxMinutes + 70,
                color: Colors.grey[200],
              ),
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Lỗi khi tải dữ liệu"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có dữ liệu"));
        }

        Map<String, int> timeUseData = snapshot.data!;
        int maxTime = timeUseData.values.reduce((a, b) => a > b ? a : b);
        List<MapEntry<String, int>> entries = timeUseData.entries.toList();

        // Tính số lượng page (mỗi page 7 ngày)
        int pageCount = (entries.length / 7).ceil();

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 3),
                          child: Text(
                            'Thời gian dùng',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: PageView.builder(
                        reverse: true,
                        itemCount: pageCount,
                        itemBuilder: (context, pageIndex) {
                          int startIndex = pageIndex * 7;
                          return SizedBox(
                            width: 7 * 56.0, // Chiều rộng cho 7 cột
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
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        int index = startIndex + value.toInt();
                                        if (index >= 0 &&
                                            index < entries.length) {
                                          String dateStr = entries[index].key;
                                          DateTime date =
                                              DateTime.parse(dateStr);
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
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
                                gridData: FlGridData(show: false),
                              ),
                            ),
                          );
                        },
                      ),
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
