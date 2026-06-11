import 'package:flutter/material.dart';

class MoodDetailsScreen extends StatelessWidget {
  const MoodDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold
        ),
      ),
      body: const Center(
        child: Text(
          'Your detailed mood analysis will appear here.',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}