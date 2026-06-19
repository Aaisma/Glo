import 'package:flutter/material.dart';

class SkinTrackerScreen extends StatelessWidget {
  const SkinTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skin Tracker"), backgroundColor: Colors.pink),
      body: const Center(child: Text("Skin Tracker Screen")),
    );
  }
}
