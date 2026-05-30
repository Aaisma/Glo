import 'package:flutter/material.dart';
import 'journal_activity_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Journal',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF3E63),
      ),
      home:JournalActivityScreen(),
    );
  }
}