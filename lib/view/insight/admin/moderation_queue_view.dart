import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/moderation_view_model.dart';
import '../../model/community_models.dart';
import 'moderation_detail_view.dart';

class ModerationQueueView extends StatefulWidget {
  const ModerationQueueView({super.key});

  @override
  State<ModerationQueueView> createState() => _ModerationQueueViewState();
}

class _ModerationQueueViewState extends State<ModerationQueueView> {
  @override
  void initState() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsModerationQueueViewModel>().loadQueue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InsightsModerationQueueViewModel>();
    final pinkTheme = const Color(0xFFFD8CA1);
    final accentColor = const Color(0xFFFF3E63);

    final activeList = viewModel.selectedTab == 'Reported' ? viewModel.reportedItems : viewModel.hiddenItems;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Content Moderation",
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
            // Moderation Tabs
            _buildModerationTabs(viewModel, accentColor),

            const SizedBox(height: 12),

            // Content Queue List
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1)))
                  : activeList.isEmpty
                      ? const Center(
                          child: Text(
                            "Moderation queue is empty! 🌸",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: activeList.length,
                          itemBuilder: (context, index) {
                            final item = activeList[index];
                            return _buildQueueCard(context, item, viewModel);
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

  Widget _buildModerationTabs(InsightsModerationQueueViewModel viewModel, Color accent) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabChip("Reported", viewModel.reportedCount, viewModel),
          const SizedBox(width: 16),
          _buildTabChip("Hidden", viewModel.hiddenCount, viewModel),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, int count, InsightsModerationQueueViewModel vm) {
    final isSelected = vm.selectedTab == label;
    final accent = const Color(0xFFFF3E63);

    return FilterChip(
      label: Text(
        "$label ($count)",
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF332B2C),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (val) => vm.setTab(label),
      selectedColor: accent,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? accent : Colors.grey.shade200,
        ),
      ),
    );
  }

  Widget _buildQueueCard(BuildContext context, ModerationItem item, InsightsModerationQueueViewModel vm) {
    final formattedDate = DateFormat('MMM dd, hh:mm a').format(item.reportedAt);

    Color typeColor = Colors.grey;
    if (item.contentType == ModerationContentType.article) typeColor = Colors.pink;
    if (item.contentType == ModerationContentType.discussion) typeColor = Colors.deepPurple;
    if (item.contentType == ModerationContentType.poll) typeColor = Colors.blue;

    final primaryCountText = vm.selectedTab == 'Reported'
        ? "${item.reportsCount} Reports"
        : "Hidden by ${item.hiddenCount} users";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.01),
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
              // Content Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.contentType.name.toUpperCase(),
                  style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            item.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Snippet
          Text(
            item.contentSnippet,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primaryCountText,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Reasons: ${item.reasons.map((r) => r.name).join(', ')}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // View Details Eye Icon
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.grey, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ModerationDetailView(contentId: item.contentId),
                        ),
                      ).then((res) {
                        if (res == true) vm.loadQueue();
                      });
                    },
                  ),
                  // Archive icon
                  IconButton(
                    icon: const Icon(Icons.archive_outlined, color: Colors.grey, size: 20),
                    onPressed: () async {
                      await vm.archiveItem(item.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Flagged item archived! 🌸")),
                        );
                      }
                    },
                  ),
                  // Delete icon (Soft-delete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () async {
                      await vm.softDeleteItem(item.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Content soft-deleted! 🌸")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar(InsightsModerationQueueViewModel viewModel, Color activeColor) {
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
