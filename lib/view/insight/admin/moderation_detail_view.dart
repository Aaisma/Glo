import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/moderation_view_model.dart';
import '../../model/community_models.dart';

class ModerationDetailView extends StatefulWidget {
  final String contentId;
  const ModerationDetailView({super.key, required this.contentId});

  @override
  State<ModerationDetailView> createState() => _ModerationDetailViewState();
}

class _ModerationDetailViewState extends State<ModerationDetailView> {
  @override
  void initState() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModerationDetailViewModel>().loadDetail(widget.contentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ModerationDetailViewModel>();
    final pinkTheme = const Color(0xFFFD8CA1);
    final accentColor = const Color(0xFFFF3E63);

    if (viewModel.isLoading || viewModel.moderationItem == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF6F8),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1))),
      );
    }

    final item = viewModel.moderationItem!;
    final formattedDate = DateFormat('MMMM dd, yyyy').format(item.reportedAt);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
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
                      title: "Total Reports",
                      value: "${item.reportsCount}",
                      icon: Icons.report_problem_outlined,
                      color: const Color(0xFFFFE5EC),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      title: "Hidden By",
                      value: "${item.hiddenCount}",
                      icon: Icons.visibility_off_outlined,
                      color: const Color(0xFFFFF2F5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Content Preview Card
              const Text(
                "Content Preview",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFFFD6E6),
                          child: Icon(Icons.person, size: 16, color: accentColor),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "@${item.authorName}",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Reported on $formattedDate",
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.contentSnippet,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF332B2C), height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Reason Breakdown Card
              const Text(
                "Reason Breakdown",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: viewModel.reasonBreakdown.entries.map((entry) {
                    final reason = entry.key;
                    final count = entry.value;

                    String label = reason.name;
                    if (reason == ModerationReason.inappropriateContent) {
                      label = "Inappropriate Content";
                    } else {
                      label = label[0].toUpperCase() + label.substring(1);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF332B2C)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5EC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$count",
                              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Admin Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: pinkTheme),
                        foregroundColor: accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        await viewModel.archiveContent(context);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Content archived successfully! 🌸")),
                          );
                        }
                      },
                      child: const Text("Archive Content", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        await viewModel.softDeleteContent(context);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Content soft-deleted successfully! 🌸")),
                          );
                        }
                      },
                      child: const Text("Delete Content", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
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
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF3E63), size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
