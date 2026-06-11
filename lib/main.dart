import 'package:flutter/material.dart';
import 'mood_log_screen.dart'; // ✨ Universal local path import to fix line 2 errors

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Tracker App',
      home: MoodLogScreen(), // ✨ Connects smoothly with your screen class
    );
  }
}