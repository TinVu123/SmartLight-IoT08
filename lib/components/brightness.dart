import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartlight/service/firebase_realtime.dart';

class MySlider extends StatefulWidget {
  const MySlider({super.key});

  @override
  State<MySlider> createState() => _SliderExampleState();
}

double _currentSliderValue = 0;
bool sliderActive = false;

class _SliderExampleState extends State<MySlider> {
  @override
  void initState() {
    super.initState();
    // listenToLedControlChanges();
    FirebaseManager().listenToLedControlChanges(
      onDataChanged: (doSangCuaDen, nutDoiMau, nutNguon, tuDongSang) {
        if (mounted) {
          setState(() {
            if (nutNguon == '0') {
              _currentSliderValue = 0;
              sliderActive = false;
            } else {
              _currentSliderValue = doSangCuaDen;
              if (tuDongSang == '0') {
                sliderActive = true;
              } else {
                sliderActive = false;
              }
            }
          });
        }
      },
      onError: () {
        print('Lỗi khi lắng nghe dữ liệu');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.blue, // Màu thanh trượt khi đã kéo
        inactiveTrackColor: Colors.grey.shade300, // Màu thanh chưa kéo
        thumbColor: Colors.blue, // Màu của nút tròn trên thanh trượt
        overlayColor:
            Colors.blue.withOpacity(0.1), // Hiệu ứng khi nhấn vào nút trượt
        trackHeight: 8.0, // Tăng chiều cao của thanh trượt
        thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 10.0), // Tăng kích thước nút trượt
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 5,
            child: SizedBox(
              width: double.infinity,
              child: IgnorePointer(
                ignoring:
                    !sliderActive, // autoBrightness = 1 = true: không cho chỉnh độ sáng trên thành slider

                child: Slider(
                  value: _currentSliderValue,
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    setState(() {
                      _currentSliderValue = value;
                      print('Value: $_currentSliderValue');
                    });
                  },
                  onChangeEnd: (value) {
                    FirebaseManager().updateField(
                      'doSangCuaDen',
                      ((value * 255) ~/ 100).toString(),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${_currentSliderValue.toInt().toString()}%',
              style: GoogleFonts.roboto(
                textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
      // Text('20%'),
    );
  }
}
