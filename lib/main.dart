import 'package:flutter/material.dart';
import 'mood_calendar_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF5F5), // Matches your UI background
        useMaterial3: true,
      ),
      home: const MoodCalendarScreen(),
    );
  }
}
