import 'package:flutter/material.dart';
import '../models/symptom_model.dart';
import '../app_colors.dart';

class SymptomChip extends StatelessWidget {
  final SymptomModel symptom;
  final VoidCallback onTap;

  const SymptomChip({
    super.key,
    required this.symptom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: symptom.selected
              ? AppColors.lightPink
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: symptom.selected
                ? AppColors.pink
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              symptom.icon,
              color: AppColors.pink,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                symptom.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (symptom.selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.pink,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}