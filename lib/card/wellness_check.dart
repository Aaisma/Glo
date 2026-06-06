import 'package:flutter/material.dart';

class WellnessCheckCard extends StatelessWidget {
  final Map<String, String> wellness;

  const WellnessCheckCard({super.key, required this.wellness});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Column(
        children: wellness.entries.map((entry) {
          return ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFFFF3E63)),
            title: Text(entry.key),
            trailing: Text(entry.value),
          );
        }).toList(),
      ),
    );
  }
}
