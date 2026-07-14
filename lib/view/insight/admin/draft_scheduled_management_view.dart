import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/insight_view_model.dart';
import '../../../model/insight_models.dart';
import '../../../constants/ayd_colour.dart';
import 'create_insight_content_view.dart';

class DraftScheduledManagementView extends StatefulWidget {
  const DraftScheduledManagementView({super.key});

  @override
  State<DraftScheduledManagementView> createState() => _DraftScheduledManagementViewState();
}

class _DraftScheduledManagementViewState extends State<DraftScheduledManagementView> {
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

    // Filter for only drafts and scheduled
    final items = viewModel.insights.where((insight) =>
        insight.status == InsightStatus.draft ||
        insight.status == InsightStatus.scheduled).toList();

    return Scaffold(
      backgroundColor: AydColors.admin,
      appBar: AppBar(
        title: const Text(
          "Drafts & Scheduled",
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
                            SizedBox(width: 80, child: Text("Status", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            Expanded(flex: 3, child: Text("Title", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            Expanded(flex: 2, child: Text("Category", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            Expanded(flex: 2, child: Text("Target Date", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            SizedBox(width: 150, child: Text("Actions", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Table / Rows
                      Expanded(
                        child: viewModel.isLoading
                            ? const Center(child: CircularProgressIndicator(color: AydColors.adminInsightButton))
                            : items.isEmpty
                                ? const Center(child: Text("No drafts or scheduled articles found.", style: TextStyle(color: Colors.grey)))
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                    itemCount: items.length,
                                    separatorBuilder: (_, _) => const Divider(height: 16, color: Color(0xFFF0F0F0)),
                                    itemBuilder: (context, index) {
                                      final insight = items[index];
                                      return _buildInsightRow(context, insight, viewModel);
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(BuildContext context, Insight insight, InsightsLibraryViewModel vm) {
    final formattedDate = insight.publishedAt != null
        ? DateFormat('MMM dd, yyyy').format(insight.publishedAt!)
        : DateFormat('MMM dd, yyyy').format(insight.createdAt);

    Color statusColor = insight.status == InsightStatus.draft ? Colors.orange : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status Badge
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  insight.status.name.substring(0, 1).toUpperCase() + insight.status.name.substring(1),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF332B2C)),
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
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Date
          Expanded(
            flex: 2,
            child: Text(
              insight.status == InsightStatus.draft ? "--" : formattedDate,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),

          // Actions
          SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF2C3154), size: 20),
                  onPressed: () {
                    final createVm = context.read<CreateInsightViewModel>();
                    createVm.loadExistingInsight(insight);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateInsightViews(),
                      ),
                    ).then((_) => vm.loadInsights());
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () async {
                    await vm.deleteInsight(insight.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item deleted! 🌸")),
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
}
