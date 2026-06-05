import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'view/glo_splash_screen.dart';
import 'view/navigation_icon/dashboard_page.dart';
import 'view/survey_page.dart';
import 'view/dashboard_card/ovulation_period_page.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const OvulationPage(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/survey': (context) => const SurveyPage(),
      },
    );
  }
}
