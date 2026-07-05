import 'package:flutter/material.dart';
import 'package:glo/view/insight/admin/insights_library_view.dart';
import 'package:glo/view/community/admin/community_posts_library_view.dart';
import 'package:glo/view/insight/admin/moderation_queue_view.dart' as insight_mod;
import 'package:glo/view/community/admin/community_moderation_queue_view.dart' as comm_mod;


class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = const Color(0xFFFD8CA1);
    final _ = const Color(0xFFFF3E63);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Admin Portal",
          style: TextStyle(
            color: Color(0xFF332B2C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF332B2C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Management & Moderation",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              _buildAdminCard(
                context,
                title: "Insights Library",
                subtitle: "Manage, create, edit, duplicate, and schedule articles.",
                icon: Icons.article_outlined,
                color: const Color(0xFFFFE5EC),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InsightsLibraryView()),
                ),
              ),
              const SizedBox(height: 16),
              _buildAdminCard(
                context,
                title: "Community Library",
                subtitle: "Moderate discussions, review poll responses, and posts.",
                icon: Icons.forum_outlined,
                color: const Color(0xFFF0E6FF),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CommunityPostsLibraryView()),
                ),
              ),
              const SizedBox(height: 16),
              _buildAdminCard(
                context,
                title: "Insights Moderation Queue",
                subtitle: "Review flagged/reported articles, hidden counts, and soft-delete.",
                icon: Icons.gavel_outlined,
                color: const Color(0xFFE3F2FD),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const insight_mod.ModerationQueueView()),
                ),
              ),
              const SizedBox(height: 16),
              _buildAdminCard(
                context,
                title: "Community Moderation Queue",
                subtitle: "Review flagged/reported discussions & polls, hidden counts.",
                icon: Icons.gavel_outlined,
                color: const Color(0xFFE0F7FA),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const comm_mod.CommunityModerationQueueView()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xFFFF3E63), size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF332B2C),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
