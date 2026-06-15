import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/insight_view_model.dart';
import '../../../model/insight_models.dart';
import 'create_insight_content_view.dart';
import 'create_poll_view.dart';

class InsightsLibraryView extends StatefulWidget {
  const InsightsLibraryView({super.key});

  @override
  State<InsightsLibraryView> createState() => _InsightsLibraryViewState();
}

class _InsightsLibraryViewState extends State<InsightsLibraryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsLibraryViewModel>().loadInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InsightsLibraryViewModel>();
    final pinkTheme = const Color(0xFFFD8CA1);
    final accentColor = const Color(0xFFFF3E63);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Insights Library",
          style: TextStyle(color: Color(0xFF332B2C), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF332B2C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Admin Action Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateInsightViews()),
                        ).then((_) => viewModel.loadInsights());
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text("Create Article", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0E6FF),
                        foregroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreatePollView()),
                        ).then((_) => viewModel.loadInsights());
                      },
                      icon: const Icon(Icons.poll_outlined, size: 20),
                      label: const Text("Create Poll", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            _buildLibraryTabs(viewModel),

            // Table / Rows
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1)))
                  : viewModel.insights.isEmpty
                      ? const Center(child: Text("No articles found in this section 🌸", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: viewModel.insights.length,
                          itemBuilder: (context, index) {
                            final insight = viewModel.insights[index];
                            return _buildInsightRow(context, insight, viewModel);
                          },
                        ),
            ),

            // Pagination Controls
            _buildPaginationBar(viewModel, pinkTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryTabs(InsightsLibraryViewModel viewModel) {
    final tabs = ["All", "Published", "Draft", "Scheduled", "Archived"];

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = viewModel.selectedTab == tab;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF332B2C),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (val) => viewModel.setTab(tab),
              selectedColor: const Color(0xFFFF3E63),
              backgroundColor: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFFF3E63) : Colors.grey.shade200,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightRow(BuildContext context, Insight insight, InsightsLibraryViewModel vm) {
    final formattedDate = insight.publishedAt != null
        ? DateFormat('MMM dd, yyyy').format(insight.publishedAt!)
        : DateFormat('MMM dd, yyyy').format(insight.createdAt);

    Color statusColor = Colors.grey;
    if (insight.status == InsightStatus.published) statusColor = Colors.green;
    if (insight.status == InsightStatus.draft) statusColor = Colors.orange;
    if (insight.status == InsightStatus.scheduled) statusColor = Colors.blue;
    if (insight.status == InsightStatus.archived) statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              insight.status.name.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${insight.category} • $formattedDate",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Action Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.grey, size: 20),
                onPressed: () async {
                  await vm.duplicateInsight(insight.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Draft duplicated! 🌸")),
                    );
                  }
                },
              ),
              if (insight.status != InsightStatus.archived)
                IconButton(
                  icon: const Icon(Icons.archive_outlined, color: Colors.grey, size: 20),
                  onPressed: () async {
                    await vm.archiveInsight(insight.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Article archived! 🌸")),
                      );
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar(InsightsLibraryViewModel viewModel, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 14),
            onPressed: viewModel.currentPage > 1 ? viewModel.prevPage : null,
          ),
          const SizedBox(width: 12),
          Text(
            "Page ${viewModel.currentPage}",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 14),
            onPressed: viewModel.hasMore ? viewModel.nextPage : null,
          ),
        ],
      ),
    );
  }
}
