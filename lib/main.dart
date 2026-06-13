import 'package:flutter/material.dart';
import 'package:gloclone/wellness_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wellness Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.pink,
      ),
      home: const WellnessDashboardScreen(),
    );
  }
}

// Paste your entire WellnessDashboardScreen code directly below this line!