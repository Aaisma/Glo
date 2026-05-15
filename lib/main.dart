import 'package:flutter/material.dart';
import 'calendar_screen.dart'; // your calendar UI
import 'register.dart'; // your register UI

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glo App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      // Start with Register screen
      home: const RegisterScreen(),
    );
  }
}
