import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/community_view_model.dart';
import '../../../model/community_models.dart';
import '../../../repo/community_repo.dart';
import '../../insight/user/poll_detail_view.dart';
import 'discussion_detail_view.dart';
import 'create_discussion_view.dart';
import 'create_poll_view.dart';

class CommunityDiscussionsView extends StatefulWidget {
  const CommunityDiscussionsView({super.key});

  @override
  State<CommunityDiscussionsView> createState() => _CommunityDiscussionsViewState();
}

class _CommunityDiscussionsViewState extends State<CommunityDiscussionsView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityFeedViewModel>().loadFeed(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final viewModel = context.read<CommunityFeedViewModel>();
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityFeedViewModel>();
    const pinkTheme = Color(0xFFFD8CA1);
    const accentColor = Color(0xFFFF3E63);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Community discussions",
          style: TextStyle(
            color: Color(0xFF332B2C),
            fontWeight: FontWeight.bold,
          ),
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => viewModel.setSearchQuery(val),
                  decoration: const InputDecoration(
                    hintText: "Search conversations, topics...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Feed List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => viewModel.loadFeed(isRefresh: true),
                color: pinkTheme,
                child: viewModel.isLoading && viewModel.feedItems.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1)))
                    : viewModel.error != null
                        ? Center(child: Text("Error: ${viewModel.error}"))
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                            itemCount: viewModel.feedItems.length + (viewModel.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == viewModel.feedItems.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(color: Color(0xFFFD8CA1)),
                                    ),
                                  );
                                }

                                final item = viewModel.feedItems[index];
                                if (item is Discussion) {
                                  return _buildDiscussionCard(context, item, accentColor);
                                } else if (item is CommunityPoll) {
                                  return _buildPollCard(context, item, pinkTheme, accentColor);
                                }
                                return const SizedBox.shrink();
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _showCreateSelectorDialog(context);
        },
      ),
    );
  }

  void _showCreateSelectorDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: const Color(0xFFFFF6F8),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create Community Post",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF0E6FF), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.deepPurple),
                ),
                title: const Text("Start a Discussion", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Ask questions, share advice, or tell a story"),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateDiscussionView()),
                  ).then((_) => context.read<CommunityFeedViewModel>().loadFeed(isRefresh: true));
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.poll_outlined, color: Colors.blue),
                ),
                title: const Text("Create a Poll", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Gather opinions and see results instantly"),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreatePollView()),
                  ).then((_) => context.read<CommunityFeedViewModel>().loadFeed(isRefresh: true));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiscussionCard(BuildContext context, Discussion item, Color favoriteColor) {
    final formattedDate = DateFormat('MMM dd').format(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DiscussionDetailView(discussionId: item.id)),
            ).then((_) => context.read<CommunityFeedViewModel>().loadFeed(isRefresh: true));
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFFFFE5EC),
                          child: Icon(
                            item.isAnonymous ? Icons.security : Icons.person,
                            size: 14,
                            color: const Color(0xFFFF3E63),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.isAnonymous ? "Anonymous" : "@${item.username}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF332B2C)),
                        ),
                      ],
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                const SizedBox(height: 8),
                Text(
                  item.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${item.likes}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(Icons.mode_comment_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${item.repliesCount}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text("${item.views}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPollCard(BuildContext context, CommunityPoll item, Color fillBg, Color borderHighlight) {
    final total = item.totalVotes;
    final hasVoted = item.userVotedOption != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PollDetailView(pollId: item.id)),
            ).then((_) => context.read<CommunityFeedViewModel>().loadFeed(isRefresh: true));
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "POLL",
                        style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "${item.totalVotes} votes",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                const SizedBox(height: 16),

                // Show top 2 options inline
                ...item.options.keys.take(2).map((opt) {
                  final votes = item.options[opt] ?? 0;
                  final double percent = total > 0 ? (votes / total) : 0;
                  final votedThis = item.userVotedOption == opt;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: votedThis ? borderHighlight : Colors.grey.shade100,
                        width: votedThis ? 1.5 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (hasVoted)
                          FractionallySizedBox(
                            widthFactor: percent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: votedThis
                                    ? fillBg.withValues(alpha: 0.2)
                                    : Colors.pink.shade50.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: votedThis ? FontWeight.bold : FontWeight.w500,
                                  color: const Color(0xFF332B2C),
                                ),
                              ),
                              if (hasVoted)
                                Text(
                                  "${(percent * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                if (item.options.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "+ ${item.options.length - 2} more options",
                      style: TextStyle(color: borderHighlight, fontSize: 12, fontWeight: FontWeight.w600),
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
