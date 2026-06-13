import 'package:flutter/material.dart';
import 'ActivitySelectionScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glo Wellness Log',
      debugShowCheckedModeBanner: false,

      // Global Theme definitions matching your clean aesthetic
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF7F2), // Premium soft warm background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF3E63), // Core accent pink
          background: const Color(0xFFFAF7F2),
        ),
        fontFamily: 'Roboto', // Modern clean typography
      ),

      // Direct entry point to view your activity selections
      home: const ActivitySelectionScreen(),
    );
  }
}