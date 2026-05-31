import 'package:flutter/material.dart';
import 'register.dart';        // ✅ make sure file name matches
import 'calendar_screen.dart';
import 'water_tracker.dart';
import 'acne_tracker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glo App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFE4E1), // baby pink
        primaryColor: Colors.pinkAccent,
      ),
      debugShowCheckedModeBanner: false,
      home: const DashboardPage(),
      routes: {
        '/register': (context) => RegisterScreen(),   // ✅ removed const
        '/calendar': (context) => CalendarScreen(),   // ✅ removed const
        '/water': (context) => WaterTrackerScreen(),
        '/acne': (context) => AcneTrackerPage(),
      },
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text("Go to Register"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/calendar'),
              child: const Text("Go to Calendar"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/water'),
              child: const Text("Go to Water Tracker"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/acne'),
              child: const Text("Go to Acne Tracker"),
            ),
          ],
        ),
      ),
    );
  }
}
