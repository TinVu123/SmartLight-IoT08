import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smartlight/service/firebase_realtime.dart';

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
    // print('${widget.type}, $light');
  }

  void updateTimeNotification(String newValue) {
    DatabaseReference ref = FirebaseDatabase.instance.ref("TIME_NOTIFICATION");
    ref.update(
      {'state_notification': newValue},
    ).catchError((error) {
      // print("Lỗi khi cập nhật: $error");
    });
  }

  @override
  void didUpdateWidget(MySwitchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      setState(() {
        light = widget.state;
        // print(light);
      });
    }
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
          FirebaseManager().updateField('nutNguon', value ? '1' : '0');
        } else if (widget.type == 'brightness') {
          FirebaseManager().updateField('nutTuDongSang', value ? '1' : '0');
        } else if (widget.type == 'notification') {
          updateTimeNotification(value ? '1' : '0');
        }
      },
    );
  }
}
