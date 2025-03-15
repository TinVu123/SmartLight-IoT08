import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class PromodeTime extends StatefulWidget {
  const PromodeTime({super.key});

  @override
  State<PromodeTime> createState() => _PromodeTimeState();
}

class _PromodeTimeState extends State<PromodeTime> {
  int _selectedMinutes = 30;
  @override
  Widget build(BuildContext context) {
    return NumberPicker(
      value: _selectedMinutes,
      minValue: 0,
      maxValue: 100,
      step: 5,
      selectedTextStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.blue),
      onChanged: (value) {
        setState(() {
          _selectedMinutes = value;
        });
      },

    );
  }
}
