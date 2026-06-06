import 'package:flutter/material.dart';
import '../models/mood_model.dart';

class MoodCard extends StatelessWidget {
  final MoodModel mood;
  final VoidCallback onTap;

  const MoodCard({super.key, required this.mood, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: mood.isSelected ? const Color(0xFFFF3E63) : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.asset(mood.emoji, width: 60, height: 60),
                if (mood.isSelected)
                  const Icon(Icons.check_circle, color: Color(0xFFFF3E63), size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(mood.label),
          ],
        ),
      ),
    );
  }
}
