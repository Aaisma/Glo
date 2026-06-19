import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exercise"), backgroundColor: Colors.pink),
      body: const Center(child: Text("Exercise Screen")),
    );
  }
}
