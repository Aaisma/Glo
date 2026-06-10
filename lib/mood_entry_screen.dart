import 'package:flutter/material.dart';
import '../widgets/mood_options.dart';
import '../widgets/thoughts_input.dart';
import '../widgets/mood_factors.dart';
import '../widgets/custom_button.dart';

class MoodEntryScreen extends StatelessWidget {
  final DateTime date;
  const MoodEntryScreen({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood Entry - ${date.toLocal().toString().split(' ')[0]}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("How are you feeling today, Shinny? 🌸",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            MoodOptions(),
            SizedBox(height: 24),
            ThoughtsInput(),
            SizedBox(height: 24),
            MoodFactors(),
            Spacer(),
            CustomButton(label: "Save My Mood 🌸"),
          ],
        ),
      ),
    );
  }
}
