import 'package:flutter/material.dart';
import 'navigation_icon/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Again Project',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: DashboardScreen(),
    );
  }
}
