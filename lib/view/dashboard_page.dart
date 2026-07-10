import 'package:flutter/material.dart';


import '../../view/components/dashboard_card.dart';
import '../../view/components/top_navigation.dart';
import '../../view/components/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodel/period_view_model.dart';

// Navigation pages
import '../viewmodel/user_viewmodel.dart';
import 'glo_journal/JournalEntryScreen.dart';
import 'glo_profile/glo_profile.dart';
import 'insight/user/insights_feed_view.dart';
import 'glo_history/history_screen.dart';
import 'calendar_screen.dart';

// Wellness pages
import '../../view/dashboard_card/log_symptoms_page.dart';
import 'dashboard_card/ovulation_period_page.dart';

// Card pages
import 'water_tracker.dart';
import '../view/glo_medication/medication_screen.dart';
import 'acne_tracker.dart';
import '../../view/cards/skin_derma_page.dart';
import '../view/glo_mood/wellness_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const InsightsFeedView(),
    const CalendarScreen(),
    const HistoryScreen(),
    const GloProfileScreen(),
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
    final periodViewModel = context.watch<PeriodViewModel>();
    final userViewModel = context.watch<UserViewModel>();
    final user = userViewModel.user;

    final dashboardItems = [
      {"title": "Daily Journal", "image": "assets/images/dashboard/journal.png"},
      {"title": "Water Tracker", "image": "assets/images/dashboard/watertracker.png"},
      {"title": "Medications", "image": "assets/images/dashboard/medication.png"},
      {"title": "Skin Tracker", "image": "assets/images/dashboard/acnetracker.png"},
      {"title": "Visit Derma", "image": "assets/images/dashboard/skinderma.png"},
      {"title": "Mood and Wellness", "image": "assets/images/dashboard/stressandsleep.png"},
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
              TopNavigation(
                isLoggedIn: user != null,
                userName: user?.name,
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        child: Center(
                          child: Text(
                            periodViewModel.cycleDay != null ? "DAY ${periodViewModel.cycleDay}" : "DAY --",
                            style: const TextStyle(
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
                        children: [
                          Text(periodViewModel.predictionText,
                              style: const TextStyle(fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.show_chart, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                  periodViewModel.predictionDate != null
                                      ? DateFormat('MMMM dd, yyyy').format(periodViewModel.predictionDate!)
                                      : DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                                  style: const TextStyle(fontSize: 14, color: Colors.white70)),
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
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const JournalEntryScreen()));
                              break;
                            case "Water Tracker":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const WaterTrackerScreen()));
                              break;
                            case "Medications":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicationScreen(userId: '123'
                                ,)));
                              break;
                            case "Skin Tracker":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AcneTrackerPage()));
                              break;
                            case "Skin Derma":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SkinDermaPage()));
                              break;
                            case "Mood and Wellness":
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const WellnessDashboardScreen()));
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
                    const Row(
                      children: [
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
                        MaterialPageRoute(builder: (_) => const LogSymptomsPage(isPeriod: false)),
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