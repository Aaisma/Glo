import 'package:flutter/material.dart';
import '../app_colors.dart';

class WellnessCheck extends StatelessWidget {
  const WellnessCheck({super.key});

  Widget item(
      IconData icon,
      String title,
      String value,
      Color color,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.chevron_right,
            color: AppColors.pink,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Wellness Check 🌸",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          item(
            Icons.nightlight_round,
            "Sleep",
            "6h 20m",
            Colors.purple,
          ),

          item(
            Icons.water_drop,
            "Water",
            "2.2 L",
            Colors.blue,
          ),

          item(
            Icons.directions_walk,
            "Steps",
            "Moderate",
            Colors.orange,
          ),

          item(
            Icons.bolt,
            "Energy",
            "Low",
            Colors.pink,
          ),
        ],
      ),
    );
  }
}