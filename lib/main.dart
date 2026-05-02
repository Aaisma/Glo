import 'package:flutter/material.dart';
import 'calendar_screen.dart'; // make sure this file is inside lib/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calendar App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: CalendarScreen(),
    );
  }
}
