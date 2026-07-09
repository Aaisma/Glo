import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/community_view_model.dart';
import '../../../constants/ayd_colour.dart';
import '../../admin_navigation/admin_top_panel.dart';
import '../../admin_navigation/admin_sidebar.dart';
import 'community_moderation_detail_view.dart';

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
                              Expanded(flex: 2, child: Text("Author", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                              Expanded(flex: 2, child: Text("Date", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Table / Rows
                        Expanded(
                          child: viewModel.isLoading
                              ? const Center(child: CircularProgressIndicator(color: AydColors.adminCommunityButton))
                              : viewModel.selectedTab == 'Discussions'
                                  ? _buildDiscussionsTable(viewModel)
                                  : _buildPollsTable(viewModel),
                        ),

                        // Pagination Controls
                        _buildPaginationBar(viewModel),
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

  Widget _buildLibraryTabs(CommunityLibraryViewModel viewModel) {
    final tabs = ["Discussions", "Polls"];

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
              onSelected: (val) {
                setState(() => _currentPage = 1);
                viewModel.setTab(tab);
              },
              selectedColor: AydColors.adminCommunityButton,
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AydColors.adminCommunityButton : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscussionsTable(CommunityLibraryViewModel vm) {
    var filtered = vm.discussions.where((d) => d.title.toLowerCase().contains(_searchQuery)).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text("No discussions found.", style: TextStyle(color: Colors.grey)));
    }

    int totalPages = (filtered.length / _itemsPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > filtered.length) endIndex = filtered.length;
    var paginated = filtered.sublist(startIndex, endIndex);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      itemCount: paginated.length,
      separatorBuilder: (_, _) => const Divider(height: 16, color: Color(0xFFF0F0F0)),
      itemBuilder: (context, index) {
        final item = paginated[index];
        final formattedDate = DateFormat('MMM dd, yyyy').format(item.createdAt);
        final statusText = item.isDeleted ? "Deleted" : "Active";
        final statusColor = item.isDeleted ? Colors.red : Colors.green;

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
                      statusText,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF332B2C)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${item.repliesCount} replies • ${item.views} views",
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ]
                  ),
                ),
              ),

              // Author
              Expanded(
                flex: 2,
                child: Text(
                  "@${item.username}",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Date
              Expanded(
                flex: 2,
                child: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
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
      return const Center(child: Text("No polls found.", style: TextStyle(color: Colors.grey)));
    }

    int totalPages = (filtered.length / _itemsPerPage).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    if (endIndex > filtered.length) endIndex = filtered.length;
    var paginated = filtered.sublist(startIndex, endIndex);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      itemCount: paginated.length,
      separatorBuilder: (_, _) => const Divider(height: 16, color: Color(0xFFF0F0F0)),
      itemBuilder: (context, index) {
        final item = paginated[index];
        final formattedDate = DateFormat('MMM dd, yyyy').format(item.createdAt);
        final statusText = item.isDeleted ? "Deleted" : "Active";
        final statusColor = item.isDeleted ? Colors.red : Colors.green;

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
                      statusText,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.question,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF332B2C)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${item.totalVotes} votes • ${item.views} views",
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ]
                  ),
                ),
              ),

              // Author
              Expanded(
                flex: 2,
                child: Text(
                  "@${item.createdBy}",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Date
              Expanded(
                flex: 2,
                child: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationBar(CommunityLibraryViewModel vm) {
    var filtered = vm.selectedTab == 'Discussions' 
      ? vm.discussions.where((d) => d.title.toLowerCase().contains(_searchQuery)).toList()
      : vm.polls.where((p) => p.question.toLowerCase().contains(_searchQuery)).toList();
    
    if (filtered.isEmpty) return const SizedBox.shrink();

    int totalPages = (filtered.length / _itemsPerPage).ceil();
    int startItem = _itemsPerPage * (_currentPage - 1) + 1;
    int endItem = (_itemsPerPage * _currentPage).clamp(0, filtered.length);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              "Showing $startItem-$endItem of ${filtered.length}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.chevron_left, size: 18, color: Colors.grey),
            onPressed: _currentPage > 1 ? () {
              setState(() => _currentPage--);
            } : null,
          ),
          const SizedBox(width: 8),
          Text("$_currentPage", style: const TextStyle(fontWeight: FontWeight.bold, color: AydColors.adminCommunityButton, fontSize: 12)),
          const SizedBox(width: 8),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            onPressed: _currentPage < totalPages ? () {
              setState(() => _currentPage++);
            } : null,
          ),
        ],
      ),
    );
  }
}
