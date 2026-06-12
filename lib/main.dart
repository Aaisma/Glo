import 'package:flutter/material.dart';
import 'mood_summary_screen.dart';
import 'wellness_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' Your Mood Summary',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFFFF8FA),
      ),
      home: MoodSummaryScreen(), // entry screen
    );
  }
}
