import 'package:flutter/material.dart';

class MoodFactors extends StatelessWidget {
  final List<Map<String, String>> factors = [
    {"emoji": "🛏️", "label": "Sleep"},
    {"emoji": "🥗", "label": "Food"},
    {"emoji": "🏋️", "label": "Exercise"},
    {"emoji": "📘", "label": "Study"},
    {"emoji": "💼", "label": "Work"},
    {"emoji": "👫", "label": "Friends"},
    {"emoji": "🏠", "label": "Family"},
    {"emoji": "🌤️", "label": "Weather"},
    {"emoji": "…", "label": "Other"},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: factors.map((f) {
        return FilterChip(
          label: Text("${f['emoji']} ${f['label']}"),
          selected: false,
          onSelected: (_) {},
        );
      }).toList(),
    );
  }
}
