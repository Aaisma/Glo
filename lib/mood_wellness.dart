import 'package:flutter/material.dart';
import 'card/mood_card.dart';
import 'card/symptom_chip.dart';
import 'card/talk.dart';
import 'card/wellness_check.dart';
import 'card/mood_progress.dart'; // ✅ make sure this file exists
import 'models/mood_model.dart';
import 'models/symptom_model.dart';

class MoodWellnessScreen extends StatefulWidget {
  const MoodWellnessScreen({super.key});

  @override
  State<MoodWellnessScreen> createState() => _MoodWellnessScreenState();
}

class _MoodWellnessScreenState extends State<MoodWellnessScreen> {
  List<MoodModel> moods = [
    MoodModel("Amazing", "assets/images/amazing.png"),
    MoodModel("Happy", "assets/images/happy.png"),
    MoodModel("Calm", "assets/images/calm.png"),
    MoodModel("Tired", "assets/images/tired.png"),
    MoodModel("Sad", "assets/images/sad.png"),
    MoodModel("Angry", "assets/images/angry.png"),
  ];

  List<SymptomModel> symptoms = [
    SymptomModel("Cramps"),
    SymptomModel("Bloating"),
    SymptomModel("Headache"),
    SymptomModel("Acne"),
    SymptomModel("Low Energy"),
    SymptomModel("Stress"),
    SymptomModel("Anxiety"),
    SymptomModel("Back Pain"),
    SymptomModel("Tender Breasts"),
    SymptomModel("+ More"),
  ];

  Map<String, String> wellness = {
    "Sleep": "6h 20m",
    "Water": "2.2 L",
    "Steps": "Moderate",
    "Energy": "Low",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood & Wellness Tracker"),
        backgroundColor: const Color(0xFFFF3E63),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Greeting Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Good Evening, Shiny 🌸",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Your feelings matter, always ✨",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Mood Selector Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("How are you feeling today?",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: moods.length,
                        itemBuilder: (context, index) {
                          return MoodCard(
                            mood: moods[index],
                            onTap: () {
                              setState(() {
                                for (var m in moods) m.isSelected = false;
                                moods[index].isSelected = true;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Symptoms Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Track your symptoms",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: symptoms.map((s) {
                        return SymptomChip(
                          symptom: s,
                          onTap: () {
                            setState(() => s.isSelected = !s.isSelected);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Talk Card
            const TalkCard(),

            const SizedBox(height: 20),

            // Wellness Check Card
            WellnessCheckCard(wellness: wellness),

            const SizedBox(height: 20),

            // Mood Progress Card
            MoodProgress(moods: moods.map((m) => m.label).toList()),
          ],
        ),
      ),
    );
  }
}
