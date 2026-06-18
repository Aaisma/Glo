import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/community_view_model.dart';
import '../../model/community_models.dart';

class CommunityPostsLibraryView extends StatefulWidget {
  const CommunityPostsLibraryView({super.key});

  @override
  State<CommunityPostsLibraryView> createState() => _CommunityPostsLibraryViewState();
}

class _CommunityPostsLibraryViewState extends State<CommunityPostsLibraryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityLibraryViewModel>().loadLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityLibraryViewModel>();
    final pinkTheme = const Color(0xFFFD8CA1);
    final accentColor = const Color(0xFFFF3E63);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
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
        child: Column(
          children: [
            // Filter Selector Tabs
            _buildLibraryTabs(viewModel),

            const SizedBox(height: 12),

            // Content Table list
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1)))
                  : viewModel.selectedTab == 'Discussions'
                      ? _buildDiscussionsList(context, viewModel, accentColor)
                      : _buildPollsList(context, viewModel, accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryTabs(CommunityLibraryViewModel viewModel) {
    final tabs = ["Discussions", "Polls"];

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: tabs.map((tab) {
          final isSelected = viewModel.selectedTab == tab;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
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
        }).toList(),
      ),
    );
  }

  Widget _buildDiscussionsList(BuildContext context, CommunityLibraryViewModel vm, Color accent) {
    if (vm.discussions.isEmpty) {
      return const Center(child: Text("No discussions found 🌸", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: vm.discussions.length,
      itemBuilder: (context, index) {
        final item = vm.discussions[index];
        final formattedDate = DateFormat('MMM dd, yyyy').format(item.createdAt);
        final statusText = item.isDeleted ? "DELETED" : "ACTIVE";
        final statusColor = item.isDeleted ? Colors.red : Colors.green;

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "By @${item.username} • $formattedDate • ${item.repliesCount} replies • ${item.views} views",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (!item.isDeleted)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    await vm.deleteDiscussion(item.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Discussion soft-deleted! 🌸")),
                      );
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPollsList(BuildContext context, CommunityLibraryViewModel vm, Color accent) {
    if (vm.polls.isEmpty) {
      return const Center(child: Text("No polls found 🌸", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: vm.polls.length,
      itemBuilder: (context, index) {
        final item = vm.polls[index];
        final formattedDate = DateFormat('MMM dd, yyyy').format(item.createdAt);
        final statusText = item.isDeleted ? "DELETED" : "ACTIVE";
        final statusColor = item.isDeleted ? Colors.red : Colors.green;

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.question,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "By @${item.createdBy} • $formattedDate • ${item.totalVotes} votes • ${item.views} views",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (!item.isDeleted)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    await vm.deletePoll(item.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Poll soft-deleted! 🌸")),
                      );
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
