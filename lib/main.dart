import 'package:flutter/material.dart';
import 'mood_wellness.dart';


void main() {
  runApp(const GlowApp());
}

class GlowApp extends StatelessWidget {
  const GlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glow',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF6F8),
        fontFamily: 'Roboto',
      ),
      home: const MoodWellnessScreen(),
    );
  }
}