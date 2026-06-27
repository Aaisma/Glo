import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/moderation_view_model.dart';
import '../../../model/community_models.dart';
import '../../../model/shared_models.dart';
import 'community_moderation_detail_view.dart';

class CommunityModerationQueueView extends StatefulWidget {
  const CommunityModerationQueueView({super.key});

  @override
  State<CommunityModerationQueueView> createState() => _CommunityModerationQueueViewState();
}

class _CommunityModerationQueueViewState extends State<CommunityModerationQueueView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityModerationQueueViewModel>().loadQueue();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityModerationQueueViewModel>();
    const pinkTheme = Color(0xFFFD8CA1);

    final activeList = viewModel.selectedTab == 'Reported' ? viewModel.reportedItems : viewModel.hiddenItems;
    final filteredList = activeList.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Community Moderation",
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar & Filter Button Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.toLowerCase();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Search reported content...",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
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
              const SizedBox(height: 20),

              // Moderation Tabs
              _buildModerationTabs(viewModel),
              const SizedBox(height: 20),

              // Content Table
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1)))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(flex: 1, child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
                                  Expanded(flex: 3, child: Text("Title", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
                                  Expanded(flex: 2, child: Text("Stats", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
                                  Expanded(flex: 2, child: Text("Reported At", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
                                  SizedBox(width: 100, child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12), textAlign: TextAlign.center)),
                                ],
                              ),
                            ),

                            // Table Body
                            Expanded(
                              child: filteredList.isEmpty
                                  ? const Center(
                                      child: Text("Queue is empty! 🌸", style: TextStyle(color: Colors.grey)),
                                    )
                                  : ListView.separated(
                                      itemCount: filteredList.length,
                                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                                      itemBuilder: (context, index) {
                                        final item = filteredList[index];
                                        return _buildQueueTableRow(context, item, viewModel);
                                      },
                                    ),
                            ),

                            // Pagination Controls
                            _buildPaginationBar(viewModel, pinkTheme),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModerationTabs(CommunityModerationQueueViewModel viewModel) {
    return Row(
      children: [
        _buildTabChip("Reported", viewModel.reportedCount, viewModel),
        const SizedBox(width: 16),
        _buildTabChip("Hidden", viewModel.hiddenCount, viewModel),
      ],
    );
  }

  Widget _buildTabChip(String label, int count, CommunityModerationQueueViewModel vm) {
    final isSelected = vm.selectedTab == label;
    const accent = Color(0xFFFF3E63);

    return ChoiceChip(
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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? accent : Colors.grey.shade200,
        ),
      ),
    );
  }

  Widget _buildQueueTableRow(BuildContext context, ModerationItem item, CommunityModerationQueueViewModel vm) {
    final formattedDate = DateFormat('MMM dd, hh:mm a').format(item.reportedAt);

    Color typeColor = Colors.grey;
    if (item.contentType == ContentType.article) typeColor = Colors.pink;
    if (item.contentType == ContentType.discussion) typeColor = Colors.deepPurple;
    if (item.contentType == ContentType.poll) typeColor = Colors.blue;

    final statsText = vm.selectedTab == 'Reported'
        ? "${item.reportsCount} Reports"
        : "${item.hiddenCount} Hidden";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Type Badge
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.contentType.name.toUpperCase(),
                style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            flex: 3,
            child: Text(
              item.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          // Stats
          Expanded(
            flex: 2,
            child: Text(
              statsText,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          // Date
          Expanded(
            flex: 2,
            child: Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          // Actions
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.grey, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommunityModerationDetailView(contentId: item.contentId),
                      ),
                    ).then((res) {
                      if (res == true) vm.loadQueue();
                    });
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar(CommunityModerationQueueViewModel viewModel, Color activeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
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
