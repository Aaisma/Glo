  import 'package:flutter/material.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Water Tracker"), backgroundColor: Colors.pink),
      body: const Center(child: Text("Water Tracker Screen")),
    );
  }
}
