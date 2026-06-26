import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/insight_view_model.dart';
import '../../../constants/ayd_colour.dart';
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

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/admin_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF332B2C)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF332B2C)),
            onPressed: () {},
          ),
        ],
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
                        backgroundColor: AydColors.adminPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
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
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AydColors.adminPrimary,
                        side: BorderSide(color: AydColors.adminPrimary.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreatePollView()),
                        ).then((_) => viewModel.loadInsights());
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text("Create Poll", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            _buildLibraryTabs(viewModel),

            // Table Headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: const [
                  SizedBox(width: 60, child: Text("Status", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                  Expanded(flex: 3, child: Text("Title", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                  Expanded(flex: 2, child: Text("Category", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                  Expanded(flex: 2, child: Text("Date", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                  SizedBox(width: 40, child: Text("Actions", textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                ],
              ),
            ),
            const Divider(height: 1),

            // Table / Rows
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AydColors.adminPrimary))
                  : viewModel.insights.isEmpty
                      ? const Center(child: Text("No articles found in this section 🌸", style: TextStyle(color: Colors.grey)))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          itemCount: viewModel.insights.length,
                          separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF0F0F0)),
                          itemBuilder: (context, index) {
                            final insight = viewModel.insights[index];
                            return _buildInsightRow(context, insight, viewModel);
                          },
                        ),
            ),

            // Pagination Controls
            _buildPaginationBar(viewModel, AydColors.adminPrimary),
          ],
        ),
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
              selectedColor: AydColors.adminPrimary,
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AydColors.adminPrimary : Colors.grey.shade300,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status Badge
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  insight.status.name.substring(0, 1).toUpperCase() + insight.status.name.substring(1),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Title
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                insight.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF332B2C)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Category
          Expanded(
            flex: 2,
            child: Text(
              insight.category,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Date
          Expanded(
            flex: 2,
            child: Text(
              insight.status == InsightStatus.draft ? "--" : formattedDate,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),

          // Actions
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.more_horiz, color: Colors.grey, size: 18),
                onPressed: () {
                  // Show modal bottom sheet with actions like in mockup if needed,
                  // or just keep it as a menu button.
                },
              ),
            ),
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
          Expanded(
            child: Text(
              "Showing 1-${viewModel.insights.length} of ${viewModel.insights.length}", // Mocking total as current for visual parity
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.chevron_left, size: 18, color: Colors.grey),
            onPressed: viewModel.currentPage > 1 ? viewModel.prevPage : null,
          ),
          const SizedBox(width: 8),
          const Text("1", style: TextStyle(fontWeight: FontWeight.bold, color: AydColors.adminPrimary, fontSize: 12)),
          const SizedBox(width: 8),
          const Text("2", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 8),
          const Text("3", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 8),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            onPressed: viewModel.hasMore ? viewModel.nextPage : null,
          ),
        ],
      ),
    );
  }
}
