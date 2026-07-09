import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/insight_view_model.dart';
import '../../../model/insight_models.dart';
import 'create_insight_content_view.dart';
import 'create_poll_view.dart';
import '../../../constants/ayd_colour.dart';
import '../../admin_navigation/admin_top_panel.dart';
import '../../admin_navigation/admin_sidebar.dart';

class InsightsLibraryView extends StatefulWidget {
  const InsightsLibraryView({super.key});

  @override
  State<InsightsLibraryView> createState() => _InsightsLibraryViewState();
}

class _InsightsLibraryViewState extends State<InsightsLibraryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsLibraryViewModel>().loadInsights();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InsightsLibraryViewModel>();

    return Container(
      decoration: const BoxDecoration(
        color: AydColors.admin,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AdminTopPanel(),
        drawer: const AdminSidebar(),
        body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => context.read<InsightsLibraryViewModel>().setSearchQuery(val),
                  decoration: const InputDecoration(
                    hintText: "Search library...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            // Admin Action Buttons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AydColors.adminInsightButton,
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
                        foregroundColor: AydColors.adminInsightButton,
                        side: const BorderSide(color: AydColors.adminInsightButton),
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

            // Table Section
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1000,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Table Headers
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(width: 60, child: Text("Status", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            Expanded(flex: 3, child: Text("Title", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            Expanded(flex: 2, child: Text("Category", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            Expanded(flex: 2, child: Text("Date", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            SizedBox(width: 200, child: Text("Actions", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Table / Rows
                      Expanded(
                        child: viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator(color: AydColors.adminInsightButton))
                            : viewModel.insights.isEmpty
                                ? const Center(child: Text("No articles found in this section.", style: TextStyle(color: Colors.grey)))
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                    itemCount: viewModel.insights.length,
                                    separatorBuilder: (_, _) => const Divider(height: 16, color: Color(0xFFF0F0F0)),
                                    itemBuilder: (context, index) {
                                      final insight = viewModel.insights[index];
                                      return _buildInsightRow(context, insight, viewModel);
                                    },
                                  ),
                      ),

                      // Pagination Controls
                      _buildPaginationBar(viewModel, AydColors.adminBackground),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
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
              selectedColor: AydColors.adminInsightButton,
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AydColors.adminInsightButton : Colors.grey.shade300,
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
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF2C3154), size: 18),
                  onPressed: () {
                    final createVm = context.read<CreateInsightViewModel>();
                    createVm.loadExistingInsight(insight);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateInsightViews(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.archive_outlined, color: Color(0xFF2C3154), size: 18),
                  onPressed: () async {
                    await vm.archiveInsight(insight.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Insight archived! 🌸")),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  onPressed: () async {
                    await vm.deleteInsight(insight.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Insight deleted! 🌸")),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar(InsightsLibraryViewModel viewModel, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          const Text("1", style: TextStyle(fontWeight: FontWeight.bold, color: AydColors.adminInsightButton, fontSize: 12)),
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
