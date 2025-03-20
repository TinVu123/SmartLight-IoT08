import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MySwitchButton extends StatefulWidget {
  final String type;
  final bool state;

  const MySwitchButton({
    super.key,
    required this.state,
    required this.type,
  });

  @override
  State<MySwitchButton> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<MySwitchButton> {
  late bool light;

  @override
  void initState() {
    super.initState();
    light = widget.state;
    print('${widget.type}, $light');
  }

  @override
  void didUpdateWidget(MySwitchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      setState(() {
        light = widget.state;
        print(light);
      });
    }
  }

  void updateNut(String buttonFunction, String newValue) {
    DatabaseReference ref = FirebaseDatabase.instance.ref("LED_CONTROL/");

    ref.update({buttonFunction: newValue}).then((_) {
      print("Cập nhật $buttonFunction thành công: $newValue");
    }).catchError((error) {
      print("Lỗi khi cập nhật: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    const WidgetStateProperty<Color?> trackColor =
        WidgetStateProperty<Color?>.fromMap(
      <WidgetStatesConstraint, Color>{WidgetState.selected: Colors.blueAccent},
    );
    final WidgetStateProperty<Color?> overlayColor =
        WidgetStateProperty<Color?>.fromMap(
      <WidgetState, Color>{
        // WidgetState.disabled: Colors.grey.shade100,
      },
    );

    return Switch(
      value: light,
      overlayColor: overlayColor, // màu cho trạng thái disabled
      trackColor: trackColor, // màu cho trạng thái được chọn
      trackOutlineWidth: const WidgetStatePropertyAll<double>(0.5),
      thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
      onChanged: (bool value) {
        if (widget.type == 'light') {
          updateNut('nutNguon', value ? '1' : '0');
          print(value);
        } else if (widget.type == 'brightness') {
          updateNut('nutTuDongSang', value ? '1' : '0');
          print(value);
        } else if (widget.type == 'promodo') {
          print('${widget.type}: $light');
        } else if (widget.type == 'notification') {
          print('${widget.type}: $light');
        }
      },
    );
  }
}
