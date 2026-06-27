import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/moderation_view_model.dart';
import '../../../model/community_models.dart';
import '../../../model/shared_models.dart';
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
    const pinkTheme = Color(0xFFFD8CA1);
    const accentColor = Color(0xFFFF3E63);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF332B2C)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Moderation Tabs
            _buildModerationTabs(viewModel, accentColor),

            const SizedBox(height: 12),

            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Search content...",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: Color(0xFF332B2C)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Table Headers
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text("Content", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                  Expanded(flex: 1, child: Text("Type", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                  Expanded(flex: 2, child: Text("Reason/Status", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                  Expanded(flex: 1, child: Text("Count", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text("Actions", textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                ],
              ),
            ),
            const Divider(height: 1),

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
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          itemCount: activeList.length,
                          separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF0F0F0)),
                          itemBuilder: (context, index) {
                            final item = activeList[index];
                            return _buildQueueRow(context, item, viewModel);
                          },
                        ),
            ),

            // Pagination Controls
            _buildPaginationBar(viewModel, pinkTheme, activeList),
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
    const accent = Color(0xFFFF3E63);

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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? accent : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildQueueRow(BuildContext context, ModerationItem item, InsightsModerationQueueViewModel vm) {
    Color typeColor = Colors.grey;
    if (item.contentType == ContentType.article) typeColor = Colors.pink;
    if (item.contentType == ContentType.discussion) typeColor = Colors.deepPurple;
    if (item.contentType == ContentType.poll) typeColor = Colors.blue;

    final primaryCountText = vm.selectedTab == 'Reported' ? "${item.reportsCount}" : "${item.hiddenCount}";
    final reasonText = vm.selectedTab == 'Reported' 
      ? item.reasons.isNotEmpty ? item.reasons.first.name.substring(0, 1).toUpperCase() + item.reasons.first.name.substring(1) : "Multiple"
      : "Hidden";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Content Title
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                item.title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Type
          Expanded(
            flex: 1,
            child: Text(
              item.contentType.name.substring(0, 1).toUpperCase() + item.contentType.name.substring(1),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),

          // Reason/Status
          Expanded(
            flex: 2,
            child: Text(
              reasonText,
              style: TextStyle(fontSize: 10, color: vm.selectedTab == 'Reported' ? Colors.redAccent : Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Count
          Expanded(
            flex: 1,
            child: Text(
              primaryCountText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.grey, size: 16),
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
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.archive_outlined, color: Colors.grey, size: 16),
                  onPressed: () async {
                    await vm.archiveItem(item.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item archived! 🌸")),
                      );
                    }
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar(InsightsModerationQueueViewModel viewModel, Color activeColor, List<ModerationItem> activeList) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              "Showing 1-${activeList.length} of 15", // Mocking total for visual parity
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
          const Text("1", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF3E63), fontSize: 12)),
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
