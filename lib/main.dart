import 'package:flutter/material.dart';
import 'mood_calendar.dart'; // make sure this matches your file name

void main() {
  runApp(const MoodCalendarApp());
}

class MoodCalendarApp extends StatelessWidget {
  const MoodCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Calendar',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const MoodCalendarScreen(),
    );
  }
}
