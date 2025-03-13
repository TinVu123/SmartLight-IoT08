import 'package:flutter/material.dart';


class MySlider extends StatefulWidget {
  const MySlider({super.key});

  @override
  State<MySlider> createState() => _SliderExampleState();
}

class _SliderExampleState extends State<MySlider> {
  double _currentSliderValue = 20;
  bool year2023 = true;

  @override
  Widget build(BuildContext context) {
    return
            Slider(
              value: _currentSliderValue,
              max: 100,
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
                print(_currentSliderValue.toInt());
              },
            );
  }
}
