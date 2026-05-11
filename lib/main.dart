import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'daily_journal.dart';
import 'medication.dart';
import 'water_tracker.dart';
import 'skin_tracker.dart';
import 'sleep_stress.dart';
import 'exercise.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hormonal Acne & Wellness App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
      routes: {
        '/daily_journal': (context) => const DailyJournalScreen(),
        '/medication': (context) => const MedicationScreen(),
        '/water_tracker': (context) => const WaterTrackerScreen(),
        '/skin_tracker': (context) => const SkinTrackerScreen(),
        '/sleep_stress': (context) => const SleepStressScreen(),
        '/exercise': (context) => const ExerciseScreen(),
      },
    );
  }
}
