import 'package:flutter/material.dart';

class MoodOptions extends StatelessWidget {
  final List<Map<String, String>> moods = [
    {"emoji": "😍", "label": "Amazing"},
    {"emoji": "😊", "label": "Happy"},
    {"emoji": "😌", "label": "Calm"},
    {"emoji": "😐", "label": "Neutral"},
    {"emoji": "😔", "label": "Sad"},
    {"emoji": "😡", "label": "Angry"},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: moods.map((m) {
        return ChoiceChip(
          label: Text("${m['emoji']} ${m['label']}"),
          selected: false,
          onSelected: (_) {},
        );
      }).toList(),
    );
  }
}
