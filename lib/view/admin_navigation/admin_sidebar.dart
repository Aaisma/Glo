import 'package:flutter/material.dart';
import '../admin_dashboard_screen.dart';
import '../admin_skin_journal_screen.dart';
import '../admin_hydration_hub_screen.dart';
import '../nutrition_tracker_screen.dart';
import '../dashboard_card/admin/admin_monthly_tracking_screen.dart';

class AdminSidebar extends StatefulWidget {
  const AdminSidebar({super.key});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  @override
  Widget build(BuildContext context) {
    final items = [
      {"icon": Icons.dashboard, "label": "Dashboard"},
      {"icon": Icons.person, "label": "Users"},
      {"icon": Icons.forum, "label": "Community Feed"},
      {"icon": Icons.bar_chart, "label": "Insights"},
      {"icon": Icons.favorite, "label": "Health Overview"},
      {"icon": Icons.spa, "label": "Wellness Journey"},
      {"icon": Icons.calendar_month, "label": "Monthly Tracking"},
      {"icon": Icons.book, "label": "Skin Journal"},
      {"icon": Icons.water_drop, "label": "Hydration Hub"},
      {"icon": Icons.restaurant_menu, "label": "Nutrition Tracker"},
      {"icon": Icons.feedback, "label": "Feedback"},
      {"icon": Icons.logout, "label": "Logout"},
    ];

    return Drawer(
      backgroundColor: const Color(0xFFF0FFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Icon(Icons.settings, color: Color(0xFF4F8FE0)),
                  SizedBox(width: 10),
                  Text("Admin Panel", style: TextStyle(color: Color(0xFF4F8FE0), fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: items.map((item) {
                  // If we need to mark active states, we can pass the current active label to AdminSidebar.
                  // For now we assume no item is "active" unless we add a parameter.
                  final isActive = false;
                  return Container(
                    color: isActive ? const Color(0xFF4F8FE0).withOpacity(0.15) : Colors.transparent,
                    child: ListTile(
                      leading: Icon(item["icon"] as IconData, color: const Color(0xFF4F8FE0)),
                      title: Text(item["label"] as String, style: const TextStyle(color: Color(0xFF2A2A2A))),
                      onTap: () {
                        Navigator.pop(context);
                        if (item["label"] == "Dashboard") {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                        } else if (item["label"] == "Skin Journal") {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSkinJournalScreen()));
                        } else if (item["label"] == "Hydration Hub") {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminHydrationHubScreen()));
                        } else if (item["label"] == "Nutrition Tracker") {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionTrackerScreen()));
                        } else if (item["label"] == "Monthly Tracking") {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMonthlyTrackingScreen()));
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}