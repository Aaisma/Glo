import 'package:flutter/material.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _mood("Amazing", "assets/images/amazing.png"),
          _mood("Happy", "assets/images/happy.png"),
          _mood("Calm", "assets/images/calm.png"),
          _mood("Sad", "assets/images/sad.png"),
          _mood("Angry", "assets/images/angry.png"),
        ],
      ),
    );
  }

  Widget _mood(String title, String img) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(img, width: 32, height: 32),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}