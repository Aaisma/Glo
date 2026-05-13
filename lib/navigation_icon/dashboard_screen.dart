import 'package:flutter/material.dart';

import '../../components/dashboard_card.dart';
import '../../components/top_navigation.dart';
import '../../components/bottom_navigation.dart';

// Navigation pages
import 'calendar_page.dart';
import 'notification_page.dart';
import 'profile_page.dart';
import 'insight_page.dart';
import 'history_page.dart';

// Wellness pages
import '../../dashboard_card/log_symptom_page.dart';
import '../../dashboard_card/ovulation_page.dart';

// Card pages
import '../../cards/daily_journal_page.dart';
import '../../cards/water_tracker_page.dart';
import '../../cards/medication_page.dart';
import '../../cards/skin_tracker_page.dart';
import '../../cards/skin_derma_page.dart';
import '../../cards/sleep_stress_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const InsightsPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final dashboardItems = [
      {"title": "Daily Journal", "image": "assets/images/journal.png"},
      {"title": "Water Tracker", "image": "assets/images/watertracker.png"},
      {"title": "Medications", "image": "assets/images/medication.png"},
      {"title": "Skin Tracker", "image": "assets/images/acnetracker.png"},
      {"title": "Skin Derma", "image": "assets/images/skinderma.png"},
      {"title": "Sleep & Stress", "image": "assets/images/stressandsleep.png"},
    ];

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const TopNavigation(),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("You’re in your",
                              style: TextStyle(fontSize: 18, color: Color(0xFF332B2C))),
                          Text("GLO....",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF3E63))),
                          Text("in sync with your body.",
                              style: TextStyle(fontSize: 16, color: Color(0xFF332B2C))),
                        ],
                      ),
                    ),
                    Image.asset(
                      "assets/images/flower.png",
                      height: screenWidth * 0.3,
                      width: screenWidth * 0.3,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const OvulationPage())),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFD8CA1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: screenWidth * 0.18,
                        height: screenWidth * 0.18,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            "DAY 23",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFD8CA1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Ovulation in 2 Days",
                              style: TextStyle(fontSize: 16, color: Colors.white)),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.show_chart, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text("April 03, 2026",
                                  style: TextStyle(fontSize: 14, color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: screenWidth < 400 ? 2/3 : 3/4,
                  ),
                  itemCount: dashboardItems.length,
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];
                    return AspectRatio(
                      aspectRatio: 3 / 4,
                      child: DashboardCard(
                        title: item["title"]!,
                        imagePath: item["image"]!,
                        onTap: () {
                          switch (item["title"]) {
                            case "Daily Journal":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyJournalPage()));
                              break;
                            case "Water Tracker":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const WaterTrackerPage()));
                              break;
                            case "Medications":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationsPage()));
                              break;
                            case "Skin Tracker":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SkinTrackerPage()));
                              break;
                            case "Skin Derma":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SkinDermaPage()));
                              break;
                            case "Sleep & Stress":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepStressPage()));
                              break;
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EDED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.local_florist, color: Color(0xFFFD8CA1)),
                        SizedBox(width: 8),
                        Text(
                          "Listen to your body,\nTrust your journey",
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFD8CA1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LogSymptomsPage()),
                      ),
                      child: const Text(
                        "Log Symptoms +",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
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
