import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/community_view_model.dart';
import '../../../model/community_models.dart';
import '../../../viewmodel/user_viewmodel.dart';
import '../../../constants/ayd_colour.dart';
import 'discussion_detail_view.dart';
import 'edit_discussion_view.dart';
import 'edit_poll_view.dart';
import 'poll_detail_view.dart';

class MyPostsView extends StatefulWidget {
  const MyPostsView({super.key});

  @override
  State<MyPostsView> createState() => _MyPostsViewState();
}

class _MyPostsViewState extends State<MyPostsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userVM = context.read<UserViewModel>();
      if (userVM.user != null) {
        context.read<MyPostsViewModel>().loadMyPosts(userVM.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyPostsViewModel>();
    final userVM = context.watch<UserViewModel>();
    final userId = userVM.user?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Posts",
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
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: ['All', 'Discussions', 'Polls'].map((tab) {
                  final isSelected = viewModel.selectedTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => viewModel.setTab(tab, userId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? AydColors.communityButton : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            tab,
                            style: TextStyle(
                              color: isSelected ? AydColors.communityButton : Colors.grey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // List
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AydColors.communityButton))
                  : viewModel.error != null
                      ? Center(child: Text("Error: ${viewModel.error}"))
                      : viewModel.items.isEmpty
                          ? const Center(child: Text("No posts found. 💙", style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              itemCount: viewModel.items.length,
                              itemBuilder: (context, index) {
                                final item = viewModel.items[index];
                                if (item is Discussion) {
                                  return _buildDiscussionCard(context, item);
                                } else if (item is CommunityPoll) {
                                  return _buildPollCard(context, item);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionCard(BuildContext context, Discussion item) {
    final formattedDate = DateFormat('MMM dd').format(item.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AydColors.communityCardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DiscussionDetailView(discussionId: item.id)),
            ).then((_) {
              final userId = context.read<UserViewModel>().user?.id ?? '';
              context.read<MyPostsViewModel>().loadMyPosts(userId);
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.mode_comment_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${item.repliesCount}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditDiscussionView(discussionId: item.id)),
                              ).then((_) {
                                final userId = context.read<UserViewModel>().user?.id ?? '';
                                context.read<MyPostsViewModel>().loadMyPosts(userId);
                              });
                            } else if (value == 'delete') {
                              final userId = context.read<UserViewModel>().user?.id ?? '';
                              await context.read<MyPostsViewModel>().deleteDiscussion(item.id, userId);
                            }
                          },
                          icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, color: AydColors.communityButton, size: 20),
                                  SizedBox(width: 8),
                                  Text("Edit", style: TextStyle(color: AydColors.communityButton)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  SizedBox(width: 8),
                                  Text("Delete", style: TextStyle(color: Colors.redAccent)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF332B2C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPollCard(BuildContext context, CommunityPoll item) {
    final formattedDate = DateFormat('MMM dd').format(item.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AydColors.communityCardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PollDetailView(pollId: item.id)),
            ).then((_) {
              final userId = context.read<UserViewModel>().user?.id ?? '';
              context.read<MyPostsViewModel>().loadMyPosts(userId);
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "POLL",
                        style: TextStyle(color: AydColors.communityButton, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditPollView(pollId: item.id)),
                              ).then((_) {
                                final userId = context.read<UserViewModel>().user?.id ?? '';
                                context.read<MyPostsViewModel>().loadMyPosts(userId);
                              });
                            } else if (value == 'delete') {
                              final userId = context.read<UserViewModel>().user?.id ?? '';
                              await context.read<MyPostsViewModel>().deletePoll(item.id, userId);
                            }
                          },
                          icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, color: AydColors.communityButton, size: 20),
                                  SizedBox(width: 8),
                                  Text("Edit", style: TextStyle(color: AydColors.communityButton)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  SizedBox(width: 8),
                                  Text("Delete", style: TextStyle(color: Colors.redAccent)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF332B2C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
