import 'package:flutter/material.dart';
import '../widgets/mood_selector.dart';
import '../widgets/symptoms_tracker.dart';
import '../widgets/journal_card.dart';
import '../widgets/wellness_card.dart';
import '../widgets/weekly_mood_chart.dart';

class MoodWellnessScreen extends StatelessWidget {
  const MoodWellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "May 24",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Good Morning,\nSam 💖",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      "assets/images/flower.png",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const MoodSelector(),

              const SizedBox(height: 12),

              const SymptomsTracker(),

              const SizedBox(height: 12),

              Expanded(
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: JournalCard(),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: WellnessCard(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const SizedBox(
                height: 150,
                child: WeeklyMoodChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}