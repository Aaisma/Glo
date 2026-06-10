import 'package:flutter/material.dart';

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  // Mood legend
  final Map<String, String> moodLegend = {
    "😍": "Amazing",
    "😊": "Happy",
    "😐": "Neutral",
    "😔": "Sad",
    "😌": "Calm",
    "😡": "Angry",
  };

  // Data for June 2026
  Map<int, String> juneMoods = {
    1: "😊", 2: "😊", 3: "😍", 4: "😐", 5: "😔", 6: "😊", 7: "😌",
    8: "😊", 9: "😡", 10: "😊", 11: "😐", 12: "😍", 13: "😔", 14: "😊",
    15: "😌", 16: "😊", 17: "😡", 18: "😊", 19: "😐", 20: "😍", 21: "😔",
    22: "😊", 23: "😌", 24: "😊", 25: "😡", 26: "😊", 27: "😐", 28: "😍",
    29: "😔", 30: "😊",
  };

  int daysInMonth = 30;
  int startWeekday = DateTime(2026, 6, 1).weekday; // Monday = 1

  List<Widget> buildCalendarCells() {
    List<Widget> cells = [];

    // Empty slots before June 1
    for (int i = 1; i < startWeekday; i++) {
      cells.add(Container());
    }

    // Days with moods
    for (int day = 1; day <= daysInMonth; day++) {
      String mood = juneMoods[day] ?? "😐";
      cells.add(
        GestureDetector(
          onTap: () {
            setState(() {
              juneMoods[day] = (juneMoods[day] == "😊") ? "😍" : "😊";
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$day", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(mood, style: const TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ),
      );
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Mood Calendar - June 2026",
            style: TextStyle(color: Colors.white)),
        actions: const [
          Icon(Icons.calendar_today, color: Colors.white),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/mood_bg.png", // <-- your background image path
              fit: BoxFit.cover,
            ),
          ),
          // Calendar content
          Column(
            children: [
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text("Mon", style: TextStyle(color: Colors.white)),
                  Text("Tue", style: TextStyle(color: Colors.white)),
                  Text("Wed", style: TextStyle(color: Colors.white)),
                  Text("Thu", style: TextStyle(color: Colors.white)),
                  Text("Fri", style: TextStyle(color: Colors.white)),
                  Text("Sat", style: TextStyle(color: Colors.white)),
                  Text("Sun", style: TextStyle(color: Colors.white)),
                ],
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 7,
                  padding: const EdgeInsets.all(12),
                  children: buildCalendarCells(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Wrap(
                  spacing: 16,
                  children: moodLegend.entries.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(entry.key,
                            style: const TextStyle(fontSize: 20, color: Colors.white)),
                        const SizedBox(width: 4),
                        Text(entry.value,
                            style: const TextStyle(color: Colors.white)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
