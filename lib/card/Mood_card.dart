import 'package:flutter/material.dart';
import '../models/mood_model.dart';
import '../app_colors.dart';

class MoodCard extends StatelessWidget {
  final MoodModel mood;
  final VoidCallback onTap;

  const MoodCard({
    super.key,
    required this.mood,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: mood.selected
                ? AppColors.pink
                : Colors.grey.shade200,
            width: mood.selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (mood.selected)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  height: 22,
                  width: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.pink,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  mood.image,
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 14),

                Text(
                  mood.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 10),

                Icon(
                  mood.icon,
                  size: 16,
                  color: mood.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
