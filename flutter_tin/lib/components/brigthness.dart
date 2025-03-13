import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';

class Brigthness extends StatefulWidget {
  const Brigthness({super.key});

  @override
  State<Brigthness> createState() => _BrigthnessState();
}
class _BrigthnessState extends State<Brigthness> {
  double _value = 0; // Chuyển biến vào trong _BrigthnessState

  @override
  Widget build(BuildContext context) {
    return InteractiveSlider(
      // startIcon: const Icon(Icons.sunny,color: Colors.yellow,),
      // centerIcon: const Text('Center'),
      // endIcon: const Icon(Icons.sunny),
      min: 1.0,
      max: 100.0,
      unfocusedHeight: 35,
      focusedHeight: 45,
      foregroundColor: Colors.white,
      // backgroundColor: Colors.red,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      // onChanged: (value) => setState(() => _value = value),
      onChanged: (value) {
        print(value);
        setState(() {
          _value = value;
        });
      },
    );
  }
}
