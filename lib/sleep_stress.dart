import 'package:flutter/material.dart';

class SleepStressScreen extends StatelessWidget {
  const SleepStressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep & Stress"), backgroundColor: Colors.pink),
      body: const Center(child: Text("Sleep & Stress Screen")),
    );
  }
}
