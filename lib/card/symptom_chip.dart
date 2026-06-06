import 'package:flutter/material.dart';
import '../models/symptom_model.dart';

class SymptomChip extends StatelessWidget {
  final SymptomModel symptom;
  final VoidCallback onTap;

  const SymptomChip({super.key, required this.symptom, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(symptom.name),
      selected: symptom.isSelected,
      selectedColor: Colors.pink.shade100,
      onSelected: (_) => onTap(),
    );
  }
}
