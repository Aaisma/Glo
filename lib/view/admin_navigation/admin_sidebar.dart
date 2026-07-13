import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/admin_monthly_tracking_viewmodel.dart';
import 'package:glo/viewmodel/insight_view_model.dart';
import 'package:glo/viewmodel/community_view_model.dart';
import 'package:glo/viewmodel/moderation_view_model.dart';
import 'package:glo/view/admin_dashboard_screen.dart';
import 'package:glo/view/glo_admin/admin_skin_journal_screen.dart';
import 'package:glo/view/glo_admin/admin_hydration_hub_screen.dart';
import 'package:glo/view/glo_admin/nutrition_dashboard.dart';
import 'package:glo/view/community/admin/community_posts_library_view.dart';
import 'package:glo/view/community/admin/community_moderation_queue_view.dart';
import 'package:glo/view/insight/admin/insights_library_view.dart';
import 'package:glo/view/insight/admin/moderation_queue_view.dart';
import 'package:glo/view/glo_admin/admin_users_page.dart';
import 'package:glo/view/authentication/logout.dart';
import 'package:glo/view/dashboard_card/admin/admin_period_analytics_screen.dart';
import 'package:glo/view/dashboard_card/admin/admin_ovulation_analytics_screen.dart';
import 'package:glo/view/dashboard_card/admin/admin_symptoms_analytics_screen.dart';
import 'package:glo/view/dashboard_card/admin/admin_symptoms_details_screen.dart';

const Color _kBrand = Color(0xFF4F8FE0);
const Color _kBrandTint = Color(0xFFEAF3FD);
const Color _kInactiveIcon = Color(0xFF8C97A6);
const Color _kInactiveText = Color(0xFF2A2A2A);
const Color _kSectionLabel = Color(0xFF9AA5B1);

class AdminSidebar extends StatefulWidget {
  const AdminSidebar({super.key});

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  // Tracks which item is currently "active" so it can be highlighted,
  // mirroring the reference design. Defaults to Dashboard.
  String _selectedLabel = "Dashboard";

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
      {"icon": Icons.restaurant_menu, "label": "Nutrition Analytics"},
      {"icon": Icons.feedback, "label": "Feedback"},
      {"icon": Icons.logout, "label": "Logout"},
    ];

    // Section headers are inserted purely visually (grouping). The
    // underlying item list, order, and navigation logic are unchanged.
    const sectionBreaks = {
      "Dashboard": "Main",
      "Community Feed": "Content",
      "Health Overview": "Health Tracking",
      "Feedback": "Account",
    };

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header — kept structurally the same (icon + "Admin Panel"),
            // just restyled to sit closer to the reference logo row.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kBrandTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.settings, color: _kBrand, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Admin Panel",
                    style: TextStyle(
                      color: Color(0xFF1D2939),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Decorative search field — visual only, matches the reference
            // layout, not wired to any search logic.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, size: 18, color: _kInactiveIcon),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: "Search for anything...",
                          hintStyle: TextStyle(
                            color: _kInactiveIcon,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  for (final item in items) ...[
                    if (sectionBreaks.containsKey(item["label"]))
                      _buildSectionHeader(sectionBreaks[item["label"]]!),
                    _buildItem(context, item),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: _kSectionLabel,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, Map<String, dynamic> item) {
    final label = item["label"] as String;
    final icon = item["icon"] as IconData;

    // Insight & Community Feed -> Library / Moderation
    if (label == "Community Feed" || label == "Insights") {
      final prefix = label == "Community Feed" ? "Community-" : "Insight-";
      final isParentActive =
          _selectedLabel == label || _selectedLabel.startsWith(prefix);

      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: Icon(icon,
                  color: isParentActive ? _kBrand : _kInactiveIcon, size: 20),
              title: Text(
                label,
                style: TextStyle(
                  color: isParentActive ? _kBrand : _kInactiveText,
                  fontWeight: isParentActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              iconColor: _kBrand,
              collapsedIconColor: _kInactiveIcon,
              children: [
                _buildSubTile(
                  context: context,
                  label: "Library",
                  activeKey: "$prefix" "Library",
                  onTap: () {
                    // Capture the ViewModel(s) BEFORE popping the drawer —
                    // once Navigator.pop(context) runs, this context (which
                    // lives inside the Drawer) starts being torn down, so
                    // any ancestor lookup done on it after that point is
                    // unreliable. Capturing first and passing the instance
                    // via ChangeNotifierProvider.value makes each pushed
                    // screen self-sufficient regardless of drawer timing.
                    if (label == "Community Feed") {
                      final vm = context.read<CommunityLibraryViewModel>();
                      setState(() => _selectedLabel = "$prefix" "Library");
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            child: const CommunityPostsLibraryView(),
                          ),
                        ),
                      );
                    } else {
                      final vm = context.read<InsightsLibraryViewModel>();
                      setState(() => _selectedLabel = "$prefix" "Library");
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            child: const InsightsLibraryView(),
                          ),
                        ),
                      );
                    }
                  },
                ),
                _buildSubTile(
                  context: context,
                  label: "Moderation",
                  activeKey: "$prefix" "Moderation",
                  onTap: () {
                    if (label == "Community Feed") {
                      final vm = context.read<CommunityModerationQueueViewModel>();
                      setState(() => _selectedLabel = "$prefix" "Moderation");
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            child: const CommunityModerationQueueView(),
                          ),
                        ),
                      );
                    } else {
                      final vm = context.read<InsightsModerationQueueViewModel>();
                      setState(() => _selectedLabel = "$prefix" "Moderation");
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: vm,
                            child: const ModerationQueueView(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Monthly Tracking -> Period / Ovulation / Log Symptom Analytics /
    // Log Symptoms Detail
    if (label == "Monthly Tracking") {
      final childKeys = [
        "Monthly-Period",
        "Monthly-Ovulation",
        "Monthly-LogSymptomAnalytics",
        "Monthly-LogSymptomsDetail",
      ];
      final isParentActive =
          _selectedLabel == label || childKeys.contains(_selectedLabel);

      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: Icon(icon,
                  color: isParentActive ? _kBrand : _kInactiveIcon, size: 20),
              title: Text(
                label,
                style: TextStyle(
                  color: isParentActive ? _kBrand : _kInactiveText,
                  fontWeight: isParentActive ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              iconColor: _kBrand,
              collapsedIconColor: _kInactiveIcon,
              children: [
                _buildSubTile(
                  context: context,
                  label: "Period Analytics",
                  activeKey: "Monthly-Period",
                  onTap: () {
                    final vm = context.read<AdminMonthlyTrackingViewModel>();
                    setState(() => _selectedLabel = "Monthly-Period");
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: const AdminPeriodAnalyticsScreen(),
                        ),
                      ),
                    );
                  },
                ),
                _buildSubTile(
                  context: context,
                  label: "Ovulation Analytics",
                  activeKey: "Monthly-Ovulation",
                  onTap: () {
                    final vm = context.read<AdminMonthlyTrackingViewModel>();
                    setState(() => _selectedLabel = "Monthly-Ovulation");
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: const AdminOvulationAnalyticsScreen(),
                        ),
                      ),
                    );
                  },
                ),
                _buildSubTile(
                  context: context,
                  label: "Log Symptom Analytics",
                  activeKey: "Monthly-LogSymptomAnalytics",
                  onTap: () {
                    final vm = context.read<AdminMonthlyTrackingViewModel>();
                    setState(
                            () => _selectedLabel = "Monthly-LogSymptomAnalytics");
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: const AdminSymptomsAnalyticsScreen(),
                        ),
                      ),
                    );
                  },
                ),
                _buildSubTile(
                  context: context,
                  label: "Log Symptoms Detail",
                  activeKey: "Monthly-LogSymptomsDetail",
                  onTap: () {
                    final vm = context.read<AdminMonthlyTrackingViewModel>();
                    setState(
                            () => _selectedLabel = "Monthly-LogSymptomsDetail");
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: const AdminSymptomsDetailsScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Plain nav items (Dashboard, Users, Health Overview, Wellness Journey,
    // Skin Journal, Hydration Hub, Nutrition Analytics, Feedback, Logout)
    final isActive = _selectedLabel == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isActive ? _kBrandTint : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (label != "Logout") {
              setState(() => _selectedLabel = label);
            }
            Navigator.pop(context);
            if (label == "Dashboard") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminDashboardScreen(),
                ),
              );
            } else if (label == "Users") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminUsersPage(),
                ),
              );
            } else if (label == "Skin Journal") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminSkinJournalScreen(),
                ),
              );
            } else if (label == "Hydration Hub") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminHydrationHubScreen(),
                ),
              );
            } else if (label == "Nutrition Analytics") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NutritionDashboard(),
                ),
              );
            } else if (label == "Logout") {
              LogoutDialog.show(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon,
                    size: 20, color: isActive ? _kBrand : _kInactiveIcon),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? _kBrand : _kInactiveText,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTile({
    required BuildContext context,
    required String label,
    required String activeKey,
    required VoidCallback onTap,
  }) {
    final isActive = _selectedLabel == activeKey;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 2),
      child: Material(
        color: isActive ? _kBrandTint : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding:
            const EdgeInsets.only(left: 42, top: 10, bottom: 10, right: 12),
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? _kBrand : _kInactiveText,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}