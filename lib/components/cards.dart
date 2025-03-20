import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'my_switch_button.dart';
import 'package:smartlight/components/switch_button.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData iconData;
  final String buttonFunction;
  final bool buttonState;

  const CustomCard({
    super.key,
    required this.title,
    required this.color,
    required this.iconData,
    required this.buttonFunction,
    required this.buttonState,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              iconData,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(fontSize: 22),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: MySwitchButton(
            state: buttonState,
            type: buttonFunction,
          ),
        ),
      ),
    );
  }
}
