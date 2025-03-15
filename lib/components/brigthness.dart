import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';

class Brightness extends StatefulWidget {
  final bool autoBrightness;
  const Brightness({super.key, required this.autoBrightness});

  @override
  State<Brightness> createState() => _BrightnessState();
}
class _BrightnessState extends State<Brightness> {
  double _value = 0; // Chuyển biến vào trong _BrigthnessState

  @override
  Widget build(BuildContext context) {
    return InteractiveSlider(
      startIcon: const Icon(Icons.sunny,color: Colors.yellow,),
      // centerIcon: const Text('Center'),
      // endIcon: const Icon(Icons.sunny),
      min: 1.0,
      max: 100.0,
      unfocusedHeight: 35,
      focusedHeight: 45,
      foregroundColor: Colors.white,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      onChanged: (value) {
        print('value');
        setState(() {
          _value = value;
        });
      },
    );
  }
}
