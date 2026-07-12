import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/ayd_colour.dart';
import '../../../viewmodel/community_view_model.dart';
import '../../../model/community_models.dart';
import '../../../viewmodel/user_viewmodel.dart';
import 'discussion_detail_view.dart';
import 'poll_detail_view.dart';
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
      context.read<CommunityFeedViewModel>().loadFeed();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<CommunityFeedViewModel>().loadMore();
    }
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "What would you like to share?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildCreateOption(
                    context,
                    "Discussion",
                    "Start a conversation",
                    Icons.chat_bubble_outline,
                    const Color(0xFFE3F2FD),
                    AydColors.communityButton,
                    () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CreateDiscussionView())),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCreateOption(
                    context,
                    "Poll",
                    "Ask the community",
                    Icons.poll_outlined,
                    const Color(0xFFF3E5F5),
                    Colors.purple,
                    () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CreatePollView())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: iconColor)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: iconColor.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityFeedViewModel>();
    final primaryBlue = AydColors.communityButton;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/feed/community_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Community Feed", style: TextStyle(color: Color(0xFF332B2C), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF332B2C)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: _buildSearchBar(viewModel),
            ),
            _buildFilterTabs(viewModel),
            Expanded(
              child: viewModel.isLoading && viewModel.feed.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AydColors.communityButton))
                  : RefreshIndicator(
                      onRefresh: () => viewModel.loadFeed(isRefresh: true),
                      color: AydColors.communityButton,
                      child: viewModel.feed.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 100),
                                Center(child: Text("No posts found. Start a discussion! 💙", style: TextStyle(color: Colors.grey))),
                              ],
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(20),
                              itemCount: viewModel.feed.length + (viewModel.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == viewModel.feed.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(child: CircularProgressIndicator(color: AydColors.communityButton, strokeWidth: 2)),
                                  );
                                }

                                final item = viewModel.feed[index];
                                if (item is Discussion) {
                                  return _buildDiscussionCard(context, item);
                                } else if (item is CommunityPoll) {
                                  return _buildPollCard(context, item, primaryBlue, primaryBlue);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateOptions(context),
          backgroundColor: AydColors.communityButton,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Create", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSearchBar(CommunityFeedViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => viewModel.setSearchQuery(val),
        decoration: InputDecoration(
          hintText: "Search discussions or polls...",
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    viewModel.setSearchQuery("");
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDiscussionCard(BuildContext context, Discussion item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AydColors.communityCardBackground,
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
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "DISCUSSION",
                        style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${item.views}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
                ),
                const SizedBox(height: 6),
                Text(
                  item.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AydColors.communityButton.withValues(alpha: 0.1),
                      backgroundImage: item.profileImageUrl != null && item.profileImageUrl!.isNotEmpty
                          ? NetworkImage(item.profileImageUrl!)
                          : null,
                      child: item.profileImageUrl == null || item.profileImageUrl!.isEmpty
                          ? const Icon(Icons.person, size: 12, color: AydColors.communityButton)
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "@${item.username}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                    const Spacer(),
                    const Icon(Icons.favorite_border, size: 16, color: AydColors.communityButton),
                    const SizedBox(width: 4),
                    Text("${item.likes}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    const Icon(Icons.mode_comment_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("${item.repliesCount}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
        color: AydColors.communityCardBackground,
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
                        style: TextStyle(color: AydColors.communityButton, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AydColors.communityButton.withValues(alpha: 0.1),
                      backgroundImage: item.profileImageUrl != null && item.profileImageUrl!.isNotEmpty
                          ? NetworkImage(item.profileImageUrl!)
                          : null,
                      child: item.profileImageUrl == null || item.profileImageUrl!.isEmpty
                          ? const Icon(Icons.person, size: 12, color: AydColors.communityButton)
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "@${item.username}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${item.totalVotes} votes",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
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
                      alignment: Alignment.centerLeft,
                      children: [
                        if (hasVoted)
                          FractionallySizedBox(
                            widthFactor: percent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: votedThis
                                    ? fillBg.withValues(alpha: 0.2)
                                    : fillBg.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  opt,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: votedThis ? FontWeight.bold : FontWeight.w500,
                                    color: const Color(0xFF332B2C),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasVoted)
                                Text(
                                  "${(percent * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: votedThis ? borderHighlight : Colors.black54,
                                  ),
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

  Widget _buildFilterTabs(CommunityFeedViewModel viewModel) {
    final filters = ["All", "Trending", "Following", "Unanswered"];

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = viewModel.currentFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) viewModel.setFilter(filter);
              },
              selectedColor: AydColors.communityButton,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200),
              ),
              showCheckmark: false,
              elevation: isSelected ? 2 : 0,
            ),
          );
        },
      ),
    );
  }
}
