import 'package:flutter/material.dart';

import '../../viewmodel/journal_menu_viewmodel.dart';
import '../../repo/journal_repo.dart';

import 'JournalHistoryScreen.dart';
import 'FutureLettersScreen.dart';
import 'SelfCareChecklistScreen.dart';
import 'GoalHabitReflectionScreen.dart';
import 'GratitudeJournalScreen.dart';
import 'PhysicalActivityScreen.dart';
import 'FavoritesScreen.dart';

class JournalMenuScreen extends StatefulWidget {
  const JournalMenuScreen({Key? key}) : super(key: key);

  @override
  State<JournalMenuScreen> createState() => _JournalMenuScreenState();
}

class _JournalMenuScreenState extends State<JournalMenuScreen> {
  final Color primaryTextColor = const Color(0xFF2E2E2E); // FIXED: Resolved syntax error
  final Color titleColor = const Color(0xFF2E2E2E);
  final Color subtitleColor = const Color(0xFF7A7A7A);
  final Color backgroundSoftPink = const Color(0xFFFFF5F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundSoftPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFFFF2D65), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Journal Menu',
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView( // FIXED: Replaced unconstrained inner column with a scrollable list view to prevent overflows
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          children: [
            _buildMenuItem(
              icon: Icons.history_edu,
              iconColor: const Color(0xFF6C63FF),
              bgColor: const Color(0xFFE8E7FF),
              title: 'Journal History',
              subtitle: 'View your past journals',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const JournalHistoryScreen())),
            ),
            _buildMenuItem(
              icon: Icons.mark_email_unread_outlined,
              iconColor: const Color(0xFF00B4D8),
              bgColor: const Color(0xFFE0F7FA),
              title: 'Future Letters',
              subtitle: 'Letters to your future self',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FutureLettersScreen())),
            ),
            _buildMenuItem(
              icon: Icons.check_box_outlined,
              iconColor: const Color(0xFFD66853),
              bgColor: const Color(0xFFFBEBE8),
              title: 'Self-care Checklist',
              subtitle: 'Track your self-care habits',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SelfCareChecklistScreen())),
            ),
            _buildMenuItem(
              icon: Icons.emoji_objects_outlined,
              iconColor: const Color(0xFF52B788),
              bgColor: const Color(0xFFE8F5E9),
              title: 'Goal & Habit Reflection',
              subtitle: 'Reflect on goals & habits',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GoalHabitReflectionScreen())),
            ),
            _buildMenuItem(
              icon: Icons.favorite_border,
              iconColor: const Color(0xFFE76F51),
              bgColor: const Color(0xFFFDF0ED),
              title: 'Gratitude Journal',
              subtitle: 'Write things you are grateful for',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GratitudeJournalScreen())),
            ),
            _buildMenuItem(
              icon: Icons.directions_run,
              iconColor: const Color(0xFF9B5DE5),
              bgColor: const Color(0xFFF3E8FF),
              title: 'Physical Activity',
              subtitle: 'Track your daily activities',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PhysicalActivityScreen())),
            ),
            _buildMenuItem(
              icon: Icons.star_border,
              iconColor: const Color(0xFFF15BB5),
              bgColor: const Color(0xFFFCE8F5),
              title: 'Favorites',
              subtitle: 'Your favorite journals',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: subtitleColor, size: 14),
          ],
        ),
      ),
    );
  }
}