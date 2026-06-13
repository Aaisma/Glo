import 'package:flutter/material.dart';
// Make sure this import path matches the exact location of your file!
import 'mood_garden_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker App',
      debugShowCheckedModeBanner: false,

      // Setting up a clean, modern theme matching your design profile
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFBF9F6), // Matches the warm off-white background
        fontFamily: 'Roboto', // Custom font fallback
      ),

      // Automatically launches your Mood Garden screen on start
      home: const MoodGardenScreen(),
    );
  }
}