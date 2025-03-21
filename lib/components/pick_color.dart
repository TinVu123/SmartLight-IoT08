import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartlight/service/firebase_realtime.dart';

class PickerColor extends StatefulWidget {
  const PickerColor({
    super.key,
  });

  @override
  State<PickerColor> createState() => _PickerColorState();
}

List<String> listColors = <String>['Vàng', 'Trắng'];
String selectedValue = 'Vàng';

class _PickerColorState extends State<PickerColor> {
  @override
  void initState() {
    super.initState();
    FirebaseManager().listenToLedControlChanges(
      onDataChanged: (doSangCuaDen, nutDoiMau, nutNguon, tuDongSang) {
        if (mounted) {
          setState(() {
            selectedValue = listColors[int.parse(nutDoiMau.toString())];
          });
        }
      },
      onError: () {
        print('Lỗi khi lắng nghe dữ liệu');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // width: double.infinity,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: ListTile(
          leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 175, 96, 235),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.color_lens,
                color: Colors.white,
                size: 30,
              )),
          title: Text(
            'Color',
            style: GoogleFonts.roboto(
                textStyle: TextStyle(fontSize: 20),
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
          trailing: DropdownButton(
            style: GoogleFonts.roboto(
                textStyle: TextStyle(fontSize: 20, color: Colors.black87)),
            dropdownColor: Colors.white,
            value: selectedValue,
            items: listColors.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              return setState(
                () {
                  selectedValue = value.toString();
                  FirebaseManager().updateField(
                    'nutDoiMau',
                    listColors.indexOf(selectedValue).toString(),
                  );
                },
              );
            },
          ),
          // subtitle: Text('50%'),
          // trailing: DropdownButton(items: items, onChanged: onChanged),
        ),
      ),
    );
  }
}
