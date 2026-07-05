import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/moderation_view_model.dart';
import '../../../model/community_models.dart';
import '../../../model/shared_models.dart';
import 'moderation_detail_view.dart';
import '../../../constants/ayd_colour.dart';
import '../../admin_navigation/admin_top_panel.dart';
import '../../admin_navigation/admin_sidebar.dart';

class ModerationQueueView extends StatefulWidget {
  const ModerationQueueView({super.key});

  @override
  State<ModerationQueueView> createState() => _ModerationQueueViewState();
}

class _ModerationQueueViewState extends State<ModerationQueueView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsModerationQueueViewModel>().loadQueue();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InsightsModerationQueueViewModel>();

    final activeList = viewModel.selectedTab == 'Reported' ? viewModel.reportedItems : viewModel.hiddenItems;
    final filteredList = activeList.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();

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
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Search content...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // Moderation Tabs
              _buildModerationTabs(viewModel),

              // Table Section
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 800,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Table Headers
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Expanded(flex: 3, child: Text("Content", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3154)))),
                              Expanded(flex: 1, child: Text("Type", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3154)))),
                              Expanded(flex: 2, child: Text("Reason", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3154)))),
                              Expanded(flex: 1, child: Text("Count", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3154)), textAlign: TextAlign.center)),
                              SizedBox(width: 140, child: Text("Actions", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3154)))),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Content Queue List
                        Expanded(
                          child: viewModel.isLoading
                              ? const Center(child: CircularProgressIndicator(color: AydColors.adminInsightButton))
                              : filteredList.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "Moderation queue is empty! 🌸",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                      itemCount: filteredList.length,
                                      separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF0F0F0)),
                                      itemBuilder: (context, index) {
                                        final item = filteredList[index];
                                        return _buildQueueRow(context, item, viewModel);
                                      },
                                    ),
                        ),

                        // Pagination Controls
                        _buildPaginationBar(viewModel, filteredList),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModerationTabs(InsightsModerationQueueViewModel viewModel) {
    final tabs = ["Reported", "Hidden"];
    
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final count = tab == "Reported" ? viewModel.reportedCount : viewModel.hiddenCount;
          final isSelected = viewModel.selectedTab == tab;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                "$tab ($count)",
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

  Widget _buildQueueRow(BuildContext context, ModerationItem item, InsightsModerationQueueViewModel vm) {
    Color typeColor = Colors.grey;
    if (item.contentType == ContentType.article) typeColor = Colors.pink;
    if (item.contentType == ContentType.discussion) typeColor = Colors.deepPurple;
    if (item.contentType == ContentType.poll) typeColor = Colors.blue;

    final primaryCountText = vm.selectedTab == 'Reported' ? "${item.reportsCount}" : "${item.hiddenCount}";
    final reasonText = vm.selectedTab == 'Reported' 
      ? item.reasons.isNotEmpty ? item.reasons.first.name.substring(0, 1).toUpperCase() + item.reasons.first.name.substring(1) : "Multiple"
      : "Hidden";

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModerationDetailView(contentId: item.contentId),
          ),
        ).then((res) {
          if (res == true) vm.loadQueue();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3154)),
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
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6773B3)),
            ),
          ),

          // Reason/Status
          Expanded(
            flex: 2,
            child: Text(
              reasonText,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown),
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
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
          ),

          // Actions
          SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF2C3154), size: 20),
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
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.archive_outlined, color: Color(0xFF2C3154), size: 20),
                  onPressed: () async {
                    await vm.archiveItem(item.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Item archived! 🌸")),
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
    ));
  }

  Widget _buildPaginationBar(InsightsModerationQueueViewModel viewModel, List<ModerationItem> activeList) {
    if (activeList.isEmpty) return const SizedBox.shrink();

    // Use current page and limit to calculate visual numbers
    int limit = 10;
    int startItem = limit * (viewModel.currentPage - 1) + 1;
    int endItem = (limit * viewModel.currentPage).clamp(0, activeList.length);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Showing $startItem-$endItem of ${activeList.length}",
              style: const TextStyle(color: Color(0xFF6773B3), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.chevron_left, size: 24, color: Color(0xFF6773B3)),
                onPressed: viewModel.currentPage > 1 ? viewModel.prevPage : null,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F1FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE4DAF9)),
                ),
                child: Text(
                  "${viewModel.currentPage}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6773B3), fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Text("${viewModel.currentPage + 1}", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3154), fontSize: 13)),
              const SizedBox(width: 12),
              Text("${viewModel.currentPage + 2}", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3154), fontSize: 13)),
              const SizedBox(width: 12),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.chevron_right, size: 24, color: Color(0xFF6773B3)),
                onPressed: viewModel.hasMore ? viewModel.nextPage : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
