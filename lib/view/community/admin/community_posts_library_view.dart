import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/community_view_model.dart';
import '../user/create_discussion_view.dart';
import '../user/create_poll_view.dart';
import '../../../constants/ayd_colour.dart';

class CommunityPostsLibraryView extends StatefulWidget {
  const CommunityPostsLibraryView({super.key});

  @override
  State<CommunityPostsLibraryView> createState() => _CommunityPostsLibraryViewState();
}

class _CommunityPostsLibraryViewState extends State<CommunityPostsLibraryView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityLibraryViewModel>().loadLibrary();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityLibraryViewModel>();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/admin_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Community Library",
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
                            _currentPage = 1;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Search posts...",
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
                      onPressed: () {
                        // Show filter bottom sheet
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tabs & Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLibraryTabs(viewModel),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AydColors.adminBackground,
                          side: const BorderSide(color: AydColors.adminBackground),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePollView()));
                        },
                        icon: const Icon(Icons.poll_outlined, size: 18),
                        label: const Text("Create Poll", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AydColors.adminBackground,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateDiscussionView()));
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Create Discussion", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
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
                                  Expanded(flex: 1, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
                                  Expanded(flex: 3, child: Text("Title", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
                                  Expanded(flex: 2, child: Text("Author", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
                                  Expanded(flex: 2, child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
                                  SizedBox(width: 60, child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12), textAlign: TextAlign.center)),
                                ],
                              ),
                            ),
                            
                            // Table Body
                            Expanded(
                              child: viewModel.selectedTab == 'Discussions'
                                  ? _buildDiscussionsTable(viewModel)
                                  : _buildPollsTable(viewModel),
                            ),

                            // Pagination Controls
                            _buildPaginationBar(),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildLibraryTabs(CommunityLibraryViewModel viewModel) {
    final tabs = ["Discussions", "Polls"];

    return Row(
      children: tabs.map((tab) {
        final isSelected = viewModel.selectedTab == tab;

        return Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: ChoiceChip(
            label: Text(
              tab,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF332B2C),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            selected: isSelected,
            onSelected: (val) {
              setState(() => _currentPage = 1);
              viewModel.setTab(tab);
            },
            selectedColor: const Color(0xFFFF3E63),
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? const Color(0xFFFF3E63) : Colors.grey.shade200,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDiscussionsTable(CommunityLibraryViewModel vm) {
    var filtered = vm.discussions.where((d) => d.title.toLowerCase().contains(_searchQuery)).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text("No discussions found 🌸", style: TextStyle(color: Colors.grey)));
    }

    int totalPages = (filtered.length / _itemsPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > filtered.length) endIndex = filtered.length;
    var paginated = filtered.sublist(startIndex, endIndex);

    return ListView.separated(
      itemCount: paginated.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (context, index) {
        final item = paginated[index];
        final formattedDate = DateFormat('MMM dd, yyyy').format(item.createdAt);
        final statusText = item.isDeleted ? "DELETED" : "ACTIVE";
        final statusColor = item.isDeleted ? Colors.red : Colors.green;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Status
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${item.repliesCount} replies • ${item.views} views",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Author
              Expanded(
                flex: 2,
                child: Text(
                  "@${item.username}",
                  style: const TextStyle(fontSize: 13, color: Color(0xFF332B2C)),
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
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              // Actions
              SizedBox(
                width: 60,
                child: item.isDeleted
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () async {
                          await vm.deleteDiscussion(item.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Discussion soft-deleted! 🌸")),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPollsTable(CommunityLibraryViewModel vm) {
    var filtered = vm.polls.where((p) => p.question.toLowerCase().contains(_searchQuery)).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text("No polls found 🌸", style: TextStyle(color: Colors.grey)));
    }

    int totalPages = (filtered.length / _itemsPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > filtered.length) endIndex = filtered.length;
    var paginated = filtered.sublist(startIndex, endIndex);

    return ListView.separated(
      itemCount: paginated.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (context, index) {
        final item = paginated[index];
        final formattedDate = DateFormat('MMM dd, yyyy').format(item.createdAt);
        final statusText = item.isDeleted ? "DELETED" : "ACTIVE";
        final statusColor = item.isDeleted ? Colors.red : Colors.green;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Status
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.question,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${item.totalVotes} votes • ${item.views} views",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Author
              Expanded(
                flex: 2,
                child: Text(
                  "@${item.createdBy}",
                  style: const TextStyle(fontSize: 13, color: Color(0xFF332B2C)),
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
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              // Actions
              SizedBox(
                width: 60,
                child: item.isDeleted
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () async {
                          await vm.deletePoll(item.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Poll soft-deleted! 🌸")),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationBar() {
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
            onPressed: _currentPage > 1 ? () {
              setState(() => _currentPage--);
            } : null,
          ),
          const SizedBox(width: 12),
          Text(
            "Page $_currentPage",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 14),
            onPressed: () {
              // Real logic would check if hasMore, here just simple increment for local UI pagination
              setState(() => _currentPage++);
            },
          ),
        ],
      ),
    );
  }
}
