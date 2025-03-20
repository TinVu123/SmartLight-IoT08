import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChartTime extends StatefulWidget {
  const ChartTime({super.key});

  @override
  State<ChartTime> createState() => _ChartTimeState();
}

class _ChartTimeState extends State<ChartTime> {
  // Lấy dữ liệu từ Firebase: giữ nguyên key là "2025-03-10"
  Future<Map<String, int>> getTimeUseData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("TIME_USE");

    DataSnapshot snapshot = await ref.orderByKey().limitToFirst(14).get();

    if (snapshot.exists && snapshot.value != null) {
      Map<dynamic, dynamic> rawData =
          Map<dynamic, dynamic>.from(snapshot.value as Map);

      // Giữ nguyên key là ngày đầy đủ
      Map<String, int> timeUseData = rawData.map((key, value) {
        String dateString = key.toString(); // "2025-03-10"
        int timeUsed = int.parse(value.toString());
        return MapEntry(dateString, timeUsed);
      });

      // Chuyển Map thành List<MapEntry> để sắp xếp
      List<MapEntry<String, int>> sortedList = timeUseData.entries.toList();

      // Sắp xếp theo ngày (tăng dần)
      sortedList.sort((a, b) {
        DateTime dateA =
            DateTime.parse(a.key); // Chuyển chuỗi ngày thành DateTime
        DateTime dateB = DateTime.parse(b.key);
        return dateA.compareTo(dateB); // Tăng dần
        // Để giảm dần, dùng: return dateB.compareTo(dateA);
      });

      return sortedList.asMap().map((index, entry) {
        return MapEntry(entry.key, entry.value);
      });
      // return timeUseData;
    } else {
      return {};
    }
  }

  // Tạo dữ liệu biểu đồ
  List<BarChartGroupData> generateBarData(
      List<MapEntry<String, int>> entries, int maxMunites) {
    List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < entries.length; i++) {
      double timeUsed = entries[i].value.toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: timeUsed,
              color: Colors.lightBlue,
              width: 20,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxMunites + 70, // 24 giờ
                color: Colors.grey[200],
              ),
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: getTimeUseData(),
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

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Thời gian học',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    // flex: 11,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: SizedBox(
                        width: entries.length * 56.0,
                        child: BarChart(
                          BarChartData(
                            barGroups: generateBarData(entries, maxTime),
                            maxY: maxTime + 100,
                            minY: 0,
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index >= 0 && index < entries.length) {
                                      String dateStr = entries[index].key;
                                      DateTime date = DateTime.parse(dateStr);
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text("${date.day}",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            )),
                                      ); // Trục X: ngày
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
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
