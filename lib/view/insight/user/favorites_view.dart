import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/insight_view_model.dart';
import '../../../model/insight_models.dart';
import '../../../model/community_models.dart';
import '../../../model/shared_models.dart';
import 'article_detail_view.dart';
import '../../community/user/discussion_detail_view.dart';
import 'poll_detail_view.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().loadFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FavoritesViewModel>();
    final pinkTheme = const Color(0xFFFD8CA1);

    // Filter items locally based on search query
    final query = viewModel.searchQuery.toLowerCase();

    final filteredArticles = viewModel.savedArticles.where((e) =>
        e.title.toLowerCase().contains(query) || e.summary.toLowerCase().contains(query)).toList();

    final filteredDiscussions = viewModel.savedDiscussions.where((e) =>
        e.title.toLowerCase().contains(query) || e.content.toLowerCase().contains(query)).toList();

    final filteredPolls = viewModel.savedPolls.where((e) =>
        e.question.toLowerCase().contains(query)).toList();

    int totalCount = 0;
    if (viewModel.currentTab == 'All') {
      totalCount = filteredArticles.length + filteredDiscussions.length + filteredPolls.length;
    } else if (viewModel.currentTab == 'Articles') {
      totalCount = filteredArticles.length;
    } else if (viewModel.currentTab == 'Discussions') {
      totalCount = filteredDiscussions.length;
    } else if (viewModel.currentTab == 'Polls') {
      totalCount = filteredPolls.length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Favorites",
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
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => viewModel.setSearchQuery(val),
                  decoration: const InputDecoration(
                    hintText: "Search your favorites...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Tab Bar
            _buildFavoritesTabs(viewModel),

            const SizedBox(height: 12),

            // List or Empty State
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1)))
                  : totalCount == 0
                      ? _buildEmptyState()
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          children: [
                            if (viewModel.currentTab == 'All' || viewModel.currentTab == 'Articles')
                              ...filteredArticles.map((item) => _buildArticleCard(context, item, viewModel)),
                            if (viewModel.currentTab == 'All' || viewModel.currentTab == 'Discussions')
                              ...filteredDiscussions.map((item) => _buildDiscussionCard(context, item, viewModel)),
                            if (viewModel.currentTab == 'All' || viewModel.currentTab == 'Polls')
                              ...filteredPolls.map((item) => _buildPollCard(context, item, viewModel)),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTabs(FavoritesViewModel viewModel) {
    final tabs = ["All", "Articles", "Discussions", "Polls"];

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = viewModel.currentTab == tab;

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
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 100,
            height: 100,
            color: Colors.pink.shade100,
          ),
          const SizedBox(height: 24),
          const Text(
            "No favorites yet 🌸",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF332B2C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Save articles and polls to\naccess them later.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Insight item, FavoritesViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            item.coverImage,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: const Color(0xFFFFE5EC)),
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            "${item.category} • ${item.readTime}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.bookmark, color: Color(0xFFFF3E63)),
          onPressed: () => vm.removeFavorite(item.id, ContentType.article),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ArticleDetailView(insightId: item.id)),
          );
        },
      ),
    );
  }

  Widget _buildDiscussionCard(BuildContext context, Discussion item, FavoritesViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0E6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.chat_bubble_outline, color: Colors.deepPurple, size: 24),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            "Discussion • ${item.repliesCount} replies",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Color(0xFFFF3E63)),
          onPressed: () => vm.removeFavorite(item.id, ContentType.discussion),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DiscussionDetailView(discussionId: item.id)),
          );
        },
      ),
    );
  }

  Widget _buildPollCard(BuildContext context, CommunityPoll item, FavoritesViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.poll_outlined, color: Colors.blue, size: 24),
        ),
        title: Text(
          item.question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            "Poll • ${item.totalVotes} votes",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Color(0xFFFF3E63)),
          onPressed: () => vm.removeFavorite(item.id, ContentType.poll),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PollDetailView(pollId: item.id)),
          );
        },
      ),
    );
  }
}
