import 'package:flutter/material.dart';
import 'view/authentication/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glow App',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const RegisterScreen(),
    );
  }
}
