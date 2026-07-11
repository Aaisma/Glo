import 'package:flutter/material.dart';
import '../glo_admin/admin_dashboard_screen.dart';
import '../glo_admin/admin_skin_journal_screen.dart';
import '../glo_admin/admin_hydration_hub_screen.dart';
import '../glo_admin/admin_meal_tracker_screen.dart';
import '../dashboard_card/admin/admin_monthly_tracking_screen.dart';
import '../community/admin/community_posts_library_view.dart';
import '../community/admin/community_moderation_queue_view.dart';
import '../insight/admin/insights_library_view.dart';
import '../insight/admin/moderation_queue_view.dart';
import '../glo_admin/admin_users_page.dart';
import '../authentication/logout.dart';

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
                  Text(
                    "Admin Panel",
                    style: TextStyle(
                      color: Color(0xFF4F8FE0),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: items.map((item) {
                  final isActive = false;

                  if (item["label"] == "Community Feed" ||
                      item["label"] == "Insights") {
                    return ExpansionTile(
                      leading: Icon(item["icon"] as IconData,
                          color: const Color(0xFF4F8FE0)),
                      title: Text(item["label"] as String,
                          style: const TextStyle(color: Color(0xFF2A2A2A))),
                      iconColor: const Color(0xFF4F8FE0),
                      collapsedIconColor: const Color(0xFF4F8FE0),
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 54),
                          title: const Text("Library",
                              style: TextStyle(color: Color(0xFF2A2A2A))),
                          onTap: () {
                            Navigator.pop(context);
                            if (item["label"] == "Community Feed") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const CommunityPostsLibraryView(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const InsightsLibraryView(),
                                ),
                              );
                            }
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(left: 54),
                          title: const Text("Moderation",
                              style: TextStyle(color: Color(0xFF2A2A2A))),
                          onTap: () {
                            Navigator.pop(context);
                            if (item["label"] == "Community Feed") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const CommunityModerationQueueView(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ModerationQueueView(),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }

                  return Container(
                    color: isActive
                        ? const Color(0xFF4F8FE0).withOpacity(0.15)
                        : Colors.transparent,
                    child: ListTile(
                      leading: Icon(item["icon"] as IconData,
                          color: const Color(0xFF4F8FE0)),
                      title: Text(item["label"] as String,
                          style: const TextStyle(color: Color(0xFF2A2A2A))),
                      onTap: () {
                        Navigator.pop(context);
                        if (item["label"] == "Dashboard") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminDashboardScreen(),
                            ),
                          );
                        } else if (item["label"] == "Users") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminUsersPage(),
                            ),
                          );
                        } else if (item["label"] == "Skin Journal") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminSkinJournalScreen(),
                            ),
                          );
                        } else if (item["label"] == "Hydration Hub") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminHydrationHubScreen(),
                            ),
                          );
                        } else if (item["label"] == "Nutrition Tracker") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminMealTrackerScreen(),
                            ),
                          );
                        } else if (item["label"] == "Monthly Tracking") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const AdminMonthlyTrackingScreen(),
                            ),
                          );
                        } else if (item["label"] == "Logout") {
                          LogoutDialog.show(context);
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
