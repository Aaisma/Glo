import 'package:flutter/material.dart';

class ActivitySelectionScreen extends StatefulWidget {
  const ActivitySelectionScreen({super.key});

  @override
  State<ActivitySelectionScreen> createState() => _ActivitySelectionScreenState();
}

class _ActivitySelectionScreenState extends State<ActivitySelectionScreen> {
  // Navigation Trackers
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Selected state tracking map (Key: activity title, Value: true/false)
  final Map<String, bool> _selectedActivities = {};

  // Complete Dataset matching image_fc2324.jpg
  final List<Map<String, dynamic>> _categories = [
    {
      "name": "Physical Activity",
      "color": const Color(0xFF2E7D32),
      "bgColor": const Color(0xFFE8F5E9),
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
      "name": "Self Care",
      "color": const Color(0xFF673AB7),
      "bgColor": const Color(0xFFF3E5F5),
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
      "name": "Lifestyle",
      "color": const Color(0xFFE65100),
      "bgColor": const Color(0xFFFFF3E0),
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
      "name": "Mood",
      "color": const Color(0xFF1976D2),
      "bgColor": const Color(0xFFE3F2FD),
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
    var activeCategory = _categories[_selectedCategoryIndex];
    List<dynamic> activeItems = activeCategory["items"];

    // Dynamic Filter logic for Search Box
    if (_searchController.text.isNotEmpty) {
      activeItems = activeItems
          .where((item) => item["title"]
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. App Bar Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
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
                  const SizedBox(width: 40), // Balance offset for symmetry
                ],
              ),
              const SizedBox(height: 14),

              // 2. Search Input Field Layout Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 3))
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.black38, size: 20),
                    hintText: "Search activities...",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Main Dynamic Splitted Workplace Segment Area
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN: Fixed Side Selection Rail Tabs
                    Container(
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(_categories.length, (index) {
                          bool isCurrent = _selectedCategoryIndex == index;
                          var cat = _categories[index];
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedCategoryIndex = index;
                              _searchController.clear();
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                              decoration: BoxDecoration(
                                color: isCurrent ? cat["color"] : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  cat["name"].toString().replaceAll(" ", "\n"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent ? Colors.white : Colors.black45,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // RIGHT COLUMN: Active Categorized Interactive Grids
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: activeCategory["bgColor"],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeCategory["name"],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: activeCategory["color"],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: activeItems.isEmpty
                                  ? const Center(child: Text("No items found", style: TextStyle(fontSize: 12, color: Colors.black38)))
                                  : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: activeItems.map((item) {
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
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? activeCategory["color"] : Colors.white,
                                          borderRadius: BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.02),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              item["icon"],
                                              size: 16,
                                              color: isSelected ? Colors.white : activeCategory["color"],
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Custom Activity Action Trigger Card Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFD0D6), width: 1),
                ),
                child: InkWell(
                  onTap: () {
                    // Logic to add custom parameters if needed
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 16, color: Color(0xFFFF3E63)),
                      SizedBox(width: 6),
                      Text(
                        "Add your own activity",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 5. Final Confirmation Finish Floating Layer Button
              GestureDetector(
                onTap: () {
                  List<String> selections = [];
                  _selectedActivities.forEach((key, value) {
                    if (value) selections.add(key);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Selected logs verified: ${selections.join(', ')}")),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF3E63), Color(0xFFFF7A85)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFF3E63).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Confirm & Close Selection",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}