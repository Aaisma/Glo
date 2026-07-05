import 'package:flutter/material.dart';
import 'admin_period_analytics_screen.dart';
import 'admin_ovulation_analytics_screen.dart';
import 'admin_symptoms_analytics_screen.dart';
import 'admin_symptoms_details_screen.dart';
import 'package:glo/view/dashboard_card/admin/components/admin_tracking_components.dart';
import '../../admin_navigation/admin_top_panel.dart';
import '../../admin_navigation/admin_sidebar.dart';

class AdminMonthlyTrackingScreen extends StatelessWidget {
  const AdminMonthlyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      drawer: const AdminSidebar(),
      appBar: const AdminTopPanel(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Column(
              children: [
                Text(
                  "Select Analytics",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  "Monitor cycles, ovulation trends\nand logged symptoms",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _MenuCard(
              title: "Period Analytics",
              subtitle: "Track period cycles\nand patterns",
              iconPath: Icons.water_drop,
              iconColor: const Color(0xFFFF5252),
              bgColor: const Color(0xFFFFF5F5),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPeriodAnalyticsScreen())),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              title: "Ovulation Analytics",
              subtitle: "Track ovulation and fertile\nwindow insights",
              iconPath: Icons.eco,
              iconColor: const Color(0xFF4CAF50),
              bgColor: const Color(0xFFF5FFF5),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOvulationAnalyticsScreen())),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              title: "Symptoms Analytics",
              subtitle: "Analyze logged symptoms\nand trends",
              iconPath: Icons.local_florist,
              iconColor: const Color(0xFF9C27B0),
              bgColor: const Color(0xFFFDF5FF),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSymptomsAnalyticsScreen())),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              title: "Symptoms Details",
              subtitle: "View detailed insights\nfor each symptom",
              iconPath: Icons.analytics,
              iconColor: const Color(0xFF2196F3),
              bgColor: const Color(0xFFF5F9FF),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSymptomsDetailsScreen())),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.black54),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "All analytics are aggregated & anonymized to protect user privacy. Data is updated daily.",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconPath;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bgColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconPath, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: iconColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
