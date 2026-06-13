import 'package:flutter/material.dart';

import 'mood_summary_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Summary',
      debugShowCheckedModeBanner: false,


      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFFAF9FC), // Perfect matching canvas white background
        fontFamily: 'Roboto', // Custom design fallback
      ),

      // Launces your beautiful new analytics and curves breakdown screen on boot
      home: const MoodSummaryScreen(),
    );
  }
}