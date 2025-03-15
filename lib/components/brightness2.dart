import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MySlider extends StatefulWidget {
  const MySlider({super.key});

  @override
  State<MySlider> createState() => _SliderExampleState();
}

class _SliderExampleState extends State<MySlider> {
  double _currentSliderValue = 20; // Giá trị lấy từ firebase
  bool autoBrightness = true;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.blue, // Màu thanh trượt khi đã kéo
        inactiveTrackColor: Colors.grey.shade400, // Màu thanh chưa kéo
        thumbColor: Colors.blue, // Màu của nút tròn trên thanh trượt
        overlayColor:
            Colors.blue.withOpacity(0.2), // Hiệu ứng khi nhấn vào nút trượt
        trackHeight: 8.0, // Tăng chiều cao của thanh trượt
        thumbShape: RoundSliderThumbShape(

            enabledThumbRadius: 10.0), // Tăng kích thước nút trượt
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: SizedBox(
              width: double.infinity,
              child: IgnorePointer(
                ignoring: !autoBrightness,
                child: Slider(
                  value: _currentSliderValue,
                  min: 0,
                  max: 100,
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                    print(_currentSliderValue.toInt());
                  },
                ),
              ),
            ),
          ),
          Expanded(flex: 1, child: Text('${_currentSliderValue.toInt().toString()}%',style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black87)),)),
        ],
      ),
      // Text('20%'),
    );
  }
}
