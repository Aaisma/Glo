import 'package:flutter/material.dart';

class MoodDetailsScreen extends StatelessWidget {
  const MoodDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Details')),
      body: const Center(
        child: Text('This is your Mood Details section.'),
      ),
    );
  }
}