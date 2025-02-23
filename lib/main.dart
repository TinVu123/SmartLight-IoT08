import 'package:denhoc/pages/chart_light.dart';
import 'package:denhoc/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: new ThemeData(scaffoldBackgroundColor: Colors.grey[300]),
      routes: {
        '/chart_light':(context)=> ChartLight(),

      },
    );
  }
}
