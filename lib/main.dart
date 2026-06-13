import 'package:flutter/material.dart';
import 'package:gloclone/ActivitySelectionScreen.dart';
import 'JournalEntryScreen.dart';
import 'journal_entry_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glo Wellness App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Match the background styling of your interface assets
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
        fontFamily: 'Roboto',
      ),
      home: const ActivitySelectionScreen(),
    );
  }
}