import 'package:flutter/material.dart';



class MySlider extends StatefulWidget {
  const MySlider({super.key});

  @override
  State<MySlider> createState() => _SliderExampleState();
}

class _SliderExampleState extends State<MySlider> {
  double _currentSliderValue = 20;

  @override
  Widget build(BuildContext context) {
    return  SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.blueAccent, // Màu thanh trượt khi đã kéo
        inactiveTrackColor: Colors.grey.shade400, // Màu thanh chưa kéo
        thumbColor: Colors.blue, // Màu của nút tròn trên thanh trượt
        overlayColor: Colors.blue.withOpacity(0.2), // Hiệu ứng khi nhấn vào nút trượt
        trackHeight: 6.0, // Tăng chiều cao của thanh trượt
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0), // Tăng kích thước nút trượt
      ),
      child:
          SizedBox(
            width: double.infinity,
            child: Slider(
              value: _currentSliderValue,
              min: 0,
              max: 100,
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
          ),
          // Text('20%'),
    );

  }
}
