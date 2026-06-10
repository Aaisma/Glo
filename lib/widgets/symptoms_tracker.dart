import 'package:flutter/material.dart';

class SymptomsTracker extends StatelessWidget {
  const SymptomsTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: const [
          Chip(label: Text("Headache")),
          Chip(label: Text("Cramps")),
          Chip(label: Text("Stress")),
          Chip(label: Text("Nausea")),
          Chip(label: Text("Low Energy")),
        ],
      ),
    );
  }
}