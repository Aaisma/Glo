import 'package:flutter/material.dart';
import 'glo_profile.dart';
import 'glo_otp.dart';
import 'glo_splash_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GLO App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
      ),
      home: const SplashScreen(), // start at splash
    );
  }
}
