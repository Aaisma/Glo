import 'package:flutter/material.dart';
import 'mood_wellness.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Wellness',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFFFF8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF3E63), // pink accent
        ),
      ),
      home: const MoodWellnessScreen(), // ✅ launches your screen
    );
  }
}
