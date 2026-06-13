import 'package:flutter/material.dart';

class ActivitySelectionScreen extends StatefulWidget {
  const ActivitySelectionScreen({super.key});

  @override
  State<ActivitySelectionScreen> createState() => _ActivitySelectionScreenState();
}

class _ActivitySelectionScreenState extends State<ActivitySelectionScreen> {
  // Tracking selected items globally (Key: item title, Value: selected true/false)
  final Map<String, bool> _selectedActivities = {};

  String _searchQuery = "";

  // Dataset structurally matching image_fc2324.jpg layout categories
  final List<Map<String, dynamic>> _sections = [
    {
      "categoryName": "Physical Activity",
      "primaryColor": const Color(0xFF2E7D32),
      "chipBgColor": const Color(0xFFE8F5E9),
      "items": [
        {"title": "Didn't exercise", "icon": Icons.block_rounded},
        {"title": "Yoga", "icon": Icons.self_improvement_rounded},
        {"title": "Gym", "icon": Icons.fitness_center_rounded},
        {"title": "Aerobics & dancing", "icon": Icons.music_note_rounded},
        {"title": "Swimming", "icon": Icons.pool_rounded},
        {"title": "Team sports", "icon": Icons.sports_basketball_rounded},
        {"title": "Running", "icon": Icons.directions_run_rounded},
        {"title": "Cycling", "icon": Icons.directions_bike_rounded},
        {"title": "Walking", "icon": Icons.directions_walk_rounded},
      ]
    },
    {
      "categoryName": "Self Care",
      "primaryColor": const Color(0xFF673AB7),
      "chipBgColor": const Color(0xFFF3E5F5),
      "items": [
        {"title": "Meditation", "icon": Icons.spa_rounded},
        {"title": "Breathing exercises", "icon": Icons.air_rounded},
        {"title": "Journaling", "icon": Icons.menu_book_rounded},
        {"title": "Spa day", "icon": Icons.hot_tub_rounded},
        {"title": "Extra sleep", "icon": Icons.king_bed_rounded},
        {"title": "Gratitude", "icon": Icons.favorite_rounded},
      ]
    },
    {
      "categoryName": "Lifestyle",
      "primaryColor": const Color(0xFFE65100),
      "chipBgColor": const Color(0xFFFFF3E0),
      "items": [
        {"title": "Travel", "icon": Icons.flight_takeoff_rounded},
        {"title": "Stress", "icon": Icons.bolt_rounded},
        {"title": "Alcohol", "icon": Icons.local_bar_rounded},
        {"title": "Medication", "icon": Icons.medication_rounded},
        {"title": "Disease or injury", "icon": Icons.healing_rounded},
        {"title": "Kegel exercises", "icon": Icons.accessibility_new_rounded},
      ]
    },
    {
      "categoryName": "Mood",
      "primaryColor": const Color(0xFF1976D2),
      "chipBgColor": const Color(0xFFE3F2FD),
      "items": [
        {"title": "Happy", "icon": Icons.sentiment_very_satisfied_rounded},
        {"title": "Calm", "icon": Icons.sentiment_satisfied_rounded},
        {"title": "Excited", "icon": Icons.star_rounded},
        {"title": "Sad", "icon": Icons.sentiment_very_dissatisfied_rounded},
        {"title": "Angry", "icon": Icons.sentiment_dissatisfied_rounded},
        {"title": "Tired", "icon": Icons.face_unlock_rounded},
        {"title": "Anxious", "icon": Icons.blur_on_rounded},
        {"title": "Confident", "icon": Icons.mood_rounded},
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Fixed Header Area (Stays crisp at top)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Activity Selection",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Bar Layout
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 3))
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.black38, size: 20),
                        hintText: "Search activities...",
                        hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Scrollable Workspace
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._sections.map((section) => _buildCategoryBlock(section)).toList(),
                    const SizedBox(height: 16),
                    _buildCustomActivityCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 3. Persistent Confirmation Dashboard Button at Bottom
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () {
                  List<String> activeLogs = [];
                  _selectedActivities.forEach((key, val) {
                    if (val) activeLogs.add(key);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Logged selections saved: ${activeLogs.isEmpty ? 'None' : activeLogs.join(', ')}")),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF3E63), Color(0xFFFF7A85)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFF3E63).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Confirm & Save Activities",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builder for each premium layout section
  Widget _buildCategoryBlock(Map<String, dynamic> section) {
    String categoryName = section["categoryName"];
    Color primaryColor = section["primaryColor"];
    Color chipBgColor = section["chipBgColor"];
    List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(section["items"]);

    // Filter items based on search parameters
    var filteredItems = items.where((item) {
      return item["title"].toString().toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredItems.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryName,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: filteredItems.map((item) {
              String title = item["title"];
              bool isSelected = _selectedActivities[title] ?? false;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedActivities[title] = !isSelected;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : chipBgColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item["icon"],
                        size: 16,
                        color: isSelected ? Colors.white : primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF263238),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Builder for the custom execution block at the bottom
  Widget _buildCustomActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD0D6), width: 1),
      ),
      child: InkWell(
        onTap: () {},
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: Color(0xFFFF3E63)),
            SizedBox(width: 6),
            Text(
              "Custom Activity",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
            ),
          ],
        ),
      ),
    );
  }
}