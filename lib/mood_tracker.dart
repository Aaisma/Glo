import 'package:flutter/material.dart';

class MoodTracker extends StatefulWidget {
  const MoodTracker({super.key});

  @override
  State<MoodTracker> createState() => _MoodTrackerState();
}

class _MoodTrackerState extends State<MoodTracker> {
  int selectedMood = 3;

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😌', 'label': 'Amazing'},
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😴', 'label': 'Calm'},
    {'emoji': '🥺', 'label': 'Void'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😡', 'label': 'Angry'},
  ];

  final List<String> symptoms = [
    'Cramps',
    'Bloating',
    'Headache',
    'Acne',
    'Low Energy',
    'Stress',
    'Mood Swing',
    'Back Pain',
    'Tender Breasts',
    'Food Craving',
    'Nausea',
    'More',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// Header
              const Center(
                child: Column(
                  children: [
                    Text(
                      "MOOD & WELLNESS TRACKER",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Optimize after targeting Stress & Toxins",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Top Bar
              Row(
                children: [
                  const Icon(Icons.arrow_back_ios, size: 18),
                  const Spacer(),
                  const Text(
                    "Mood & Wellness",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "How are you feeling today?",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Your feelings often drive it",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 15),

              /// Mood Cards
              SizedBox(
                height: 95,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: moods.length,
                  itemBuilder: (context, index) {
                    bool selected = selectedMood == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMood = index;
                        });
                      },
                      child: Container(
                        width: 75,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xffFFE6EC)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? const Color(0xffFF6F9D)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              moods[index]['emoji'],
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              moods[index]['label'],
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// Symptoms Title
              Row(
                children: [
                  const Text(
                    "Track your symptoms",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "+ Add custom",
                    style: TextStyle(
                      color: Colors.pink.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// Symptoms Grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: symptoms.map((symptom) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      symptom,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// Insight Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffFDEEF2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade100,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Our Insight ✨",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "You've had much in high stress. Mood swings and low phases may be linked.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Bottom Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Task ahead your day",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "You've got a meeting, backup or anything you'd like.",
                            style: TextStyle(fontSize: 12),
                          ),
                          Spacer(),
                          Text(
                            "2 / 5",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Wellness Check",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12),
                          Text("🌙 Sleep      6h 20m"),
                          SizedBox(height: 8),
                          Text("🧠 Stress     Medium"),
                          SizedBox(height: 8),
                          Text("⚡ Energy     Low"),
                          SizedBox(height: 8),
                          Text("💧 Water      2.1 L"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "Your mood this week",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    "Mood Graph Area",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}