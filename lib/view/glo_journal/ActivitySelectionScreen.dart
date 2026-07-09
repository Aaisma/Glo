import 'package:flutter/material.dart';

class ActivitySelectionScreen extends StatefulWidget {
  final Map<String, String> initialSelections;

  const ActivitySelectionScreen({super.key, required this.initialSelections});

  @override
  State<ActivitySelectionScreen> createState() => _ActivitySelectionScreenState();
}

class _ActivitySelectionScreenState extends State<ActivitySelectionScreen> {
  late Map<String, String> _currentSelections;

  // Fully synced categories containing Mood and Lifestyle chips matching image_fac5ca.png
  final Map<String, List<Map<String, dynamic>>> _activitiesCategories = {
    "Physical Activity": [
      {"name": "Didn't exercise", "icon": "🚫"},
      {"name": "Yoga", "icon": "🧘"},
      {"name": "Gym", "icon": "🏋️"},
      {"name": "Aerobics & dancing", "icon": "💃"},
      {"name": "Swimming", "icon": "🏊"},
      {"name": "Team sports", "icon": "⚽"},
      {"name": "Running", "icon": "🏃"},
      {"name": "Cycling", "icon": "🚴"},
      {"name": "Walking", "icon": "🚶"},
    ],
    "Self Care": [
      {"name": "Meditation", "icon": "🧘‍♀️"},
      {"name": "Breathing exercises", "icon": "🫁"},
      {"name": "Journaling", "icon": "📓"},
      {"name": "Spa day", "icon": "💆‍♂️"},
      {"name": "Extra sleep", "icon": "🛌"},
      {"name": "Gratitude", "icon": "💜"},
    ],
    "Lifestyle": [
      {"name": "Travel", "icon": "🏃"},
      {"name": "Stress", "icon": "⚡"},
      {"name": "Alcohol", "icon": "🍹"},
      {"name": "Medication", "icon": "💊"},
      {"name": "Disease or injury", "icon": "🩹"},
    ],
    "Mood": [
      {"name": "Happy", "icon": "😊"},
      {"name": "Calm", "icon": "😌"},
      {"name": "Excited", "icon": "🤩"},
      {"name": "Sad", "icon": "😢"},
      {"name": "Angry", "icon": "😡"},
      {"name": "Tired", "icon": "🥱"},
    ],
  };

  @override
  void initState() {
    super.initState();
    _currentSelections = Map<String, String>.from(widget.initialSelections);
  }

  void _toggleSelection(String category, String activityName) {
    setState(() {
      if (_currentSelections[category] == activityName) {
        _currentSelections[category] = "Add";
      } else {
        _currentSelections[category] = activityName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Activity Selection",
          style: TextStyle(color: Color(0xFF263238), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrolling Categories Area
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: _activitiesCategories.keys.map((category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(category),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _activitiesCategories[category]!.map((item) {
                          final isSelected = _currentSelections[category] == item["name"];
                          return GestureDetector(
                            onTap: () => _toggleSelection(category, item["name"]),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFF0F2) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFF3E63) : Colors.black12,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(item["icon"], style: const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 6),
                                  Text(
                                    item["name"],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? const Color(0xFFFF3E63) : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
              ),
            ),

            // Confirm Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3E63),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context, _currentSelections);
                  },
                  child: const Text(
                    "Confirm & Save Activities",
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Physical Activity":
        return const Color(0xFFFF3E63);
      case "Self Care":
        return const Color(0xFF673AB7);
      case "Lifestyle":
        return const Color(0xFF1976D2);
      case "Mood":
        return const Color(0xFFE65100);
      default:
        return Colors.black87;
    }
  }
}
