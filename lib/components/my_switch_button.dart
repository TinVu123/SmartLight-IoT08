import 'package:flutter/material.dart';

class MySwitchButton extends StatefulWidget {
  final String type;

  const MySwitchButton({super.key, required this.type,});

  @override
  State<MySwitchButton> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<MySwitchButton> {
  bool light = false; // Kết nối với firebase để lấy về trạng thái( nên truyền từ ngoài vào)

  @override
  Widget build(BuildContext context) {
    const WidgetStateProperty<Color?> trackColor = WidgetStateProperty<Color?>.fromMap(
      <WidgetStatesConstraint, Color>{WidgetState.selected: Colors.blueAccent},
    );
    final WidgetStateProperty<Color?> overlayColor = WidgetStateProperty<Color?>.fromMap(
      <WidgetState, Color>{
        WidgetState.selected: Colors.lightGreenAccent,

        WidgetState.disabled: Colors.grey.shade400,

      },
    );

    return Switch(
      value: light,
      overlayColor: overlayColor,
      trackColor: trackColor,
      thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
      onChanged: (bool value) {
        setState(() {
          light = !light;
        });
        if(widget.type == 'light'){
            print('${widget.type}: $light' );
        }else if(widget.type == 'brightness'){
            print('${widget.type}: $light' );
        }else if(widget.type == 'promodo'){
            print('${widget.type}: $light' );
        }else if(widget.type == 'notification'){
            print('${widget.type}: $light' );
        }

      },
    );
  }
}
