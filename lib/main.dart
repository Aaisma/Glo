import 'package:flutter/material.dart';
import 'medications_screen.dart';

void main() {
  runApp(const MedicationApp());
}

class MedicationApp extends StatelessWidget {
  const MedicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medications',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const MedicationScreen(),
    );
  }
}
