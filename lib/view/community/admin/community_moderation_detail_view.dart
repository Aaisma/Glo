import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/moderation_view_model.dart';
import '../../../model/community_models.dart';
import '../../../model/shared_models.dart';
import '../../../constants/ayd_colour.dart';
import '../user/discussion_detail_view.dart';
import '../user/poll_detail_view.dart';

class CommunityModerationDetailView extends StatefulWidget {
  final String contentId;
  const CommunityModerationDetailView({super.key, required this.contentId});

  @override
  State<CommunityModerationDetailView> createState() => _CommunityModerationDetailViewState();
}

class _CommunityModerationDetailViewState extends State<CommunityModerationDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityModerationDetailViewModel>().loadDetail(widget.contentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityModerationDetailViewModel>();
    final pinkTheme = const Color(0xFFFD8CA1);
    final accentColor = const Color(0xFFFF3E63);

    if (viewModel.isLoading || viewModel.moderationItem == null) {
      return Scaffold(
        backgroundColor: AydColors.admin,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1))),
      );
    }
    final item = viewModel.moderationItem!;
    final formattedDate = DateFormat('MMMM dd, yyyy').format(item.reportedAt);

    return Scaffold(
      backgroundColor: AydColors.admin,
      appBar: AppBar(
        title: const Text(
          "Moderation Review",
          style: TextStyle(color: Color(0xFF332B2C), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF332B2C)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards Section
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: "Reports",
                      value: "${item.reportsCount}",
                      icon: Icons.report_outlined,
                      bgColor: const Color(0xFFFFF0F3),
                      iconColor: const Color(0xFFFE2B5E),
                      valueColor: const Color(0xFF2C3154),
                      subtitle: null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: "Hidden By",
                      value: "${item.hiddenCount} Users",
                      icon: Icons.visibility_off_outlined,
                      bgColor: const Color(0xFFF4F1FA),
                      iconColor: const Color(0xFF6773B3),
                      valueColor: const Color(0xFF2C3154),
                      subtitle: null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Content Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F1FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.contentType.name.substring(0, 1).toUpperCase() + item.contentType.name.substring(1),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6773B3)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "by @${item.authorName}  •  $formattedDate",
                          style: const TextStyle(color: Color(0xFF6773B3), fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3154)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.contentSnippet,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF2C3154), height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (viewModel.replies.isNotEmpty) ...[
                // Replies Breakdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Replies (${viewModel.replies.length})",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2C3154)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiscussionDetailView(discussionId: item.contentId),
                          ),
                        );
                      },
                      child: const Text(
                        "View all",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6773B3)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                  ),
                  child: Column(
                    children: viewModel.replies.take(2).map((reply) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildMockReply(reply.username, reply.content),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Admin Action Buttons
              const Text(
                "Admin Actions",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3154)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE4DAF9)),
                        foregroundColor: const Color(0xFF6773B3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (item.contentType == ContentType.discussion) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiscussionDetailView(discussionId: item.contentId),
                            ),
                          );
                        } else if (item.contentType == ContentType.poll) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PollDetailView(pollId: item.contentId),
                            ),
                          );
                        }
                      },
                      child: const Text("View Full Content", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFDAB3)),
                        foregroundColor: const Color(0xFFFF9500),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        await viewModel.archiveContent(context);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Content archived successfully! 🌸")),
                          );
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: const Text("Archive Content", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF0F3),
                    foregroundColor: const Color(0xFFFE2B5E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await viewModel.softDeleteContent(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Content soft-deleted successfully! 🌸")),
                      );
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text("Delete Content", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required Color valueColor,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3154)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: iconColor == const Color(0xFFFE2B5E) ? iconColor : const Color(0xFF2C3154)),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockReply(String username, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.orange.shade100,
          child: const Icon(Icons.person, size: 16, color: Colors.orange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "@$username",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF6773B3)),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(fontSize: 13, color: Color(0xFF2C3154)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
