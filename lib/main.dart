import 'package:flutter/material.dart';
import 'mood_tracker_screen.dart'; // Imports your custom screen file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the red debug banner on the top right
      title: 'Mood Tracker App',
      home: MoodTrackerScreen(), // Launches your exact mood tracker layout as home
    );
  }
}