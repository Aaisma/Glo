import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../viewmodel/insight_view_model.dart';
import '../../../model/insight_models.dart';
import '../../../model/community_models.dart';
import '../../../model/shared_models.dart';
import 'article_detail_view.dart';
import 'favorites_view.dart';
import '../../community/user/community_discussions_view.dart';
import '../../community/user/discussion_detail_view.dart';

class InsightsFeedView extends StatefulWidget {
  const InsightsFeedView({super.key});

  @override
  State<InsightsFeedView> createState() => _InsightsFeedViewState();
}

class _InsightsFeedViewState extends State<InsightsFeedView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsFeedViewModel>().loadFeed(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final viewModel = context.read<InsightsFeedViewModel>();
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InsightsFeedViewModel>();
    final pinkTheme = const Color(0xFFFD8CA1);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Insights Feed",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF332B2C),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, color: Color(0xFFFF3E63), size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FavoritesView()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => viewModel.setSearchQuery(val),
                  decoration: const InputDecoration(
                    hintText: "Search articles, topics, experts...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Category Chips List
            _buildCategorySection(viewModel, pinkTheme),

            const SizedBox(height: 8),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => viewModel.loadFeed(isRefresh: true),
                color: pinkTheme,
                child: viewModel.isLoading && viewModel.latestInsights.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1)))
                    : viewModel.error != null
                        ? Center(child: Text("Error: ${viewModel.error}"))
                        : SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Featured Insight
                                if (viewModel.featuredInsight != null) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Featured Insight",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF332B2C),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFeaturedCard(context, viewModel.featuredInsight!),
                                  const SizedBox(height: 24),
                                ],

                                // Latest Insights
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      "Latest Insights",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF332B2C),
                                      ),
                                    ),
                                    Text(
                                      "See all",
                                      style: TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                if (viewModel.latestInsights.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40.0),
                                    child: Center(
                                      child: Text(
                                        "No articles found 🌸",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: viewModel.latestInsights.length + (viewModel.isLoadingMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == viewModel.latestInsights.length) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(
                                            child: CircularProgressIndicator(color: Color(0xFFFD8CA1)),
                                          ),
                                        );
                                      }
                                      return _buildInsightCard(context, viewModel.latestInsights[index]);
                                    },
                                  ),

                                const SizedBox(height: 24),

                                // Community Spotlight Section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Community Spotlight",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF332B2C),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const CommunityDiscussionsView()),
                                        );
                                      },
                                      child: const Text(
                                        "See all",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFFF3E63),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildCommunitySpotlightSection(context),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(InsightsFeedViewModel viewModel, Color activeColor) {
    final categories = ["Health & Wellness", "Lifestyle", "Community", "Expert Insights", "Trending"];

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = viewModel.selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF332B2C),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (val) => viewModel.setCategory(cat),
              selectedColor: const Color(0xFFFF3E63),
              backgroundColor: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
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

  Widget _buildFeaturedCard(BuildContext context, Insight insight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleDetailView(insightId: insight.id),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                insight.coverImage,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: const Color(0xFFFFE5EC),
                  child: const Icon(Icons.image, size: 50, color: Colors.pink),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE5EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            insight.category,
                            style: const TextStyle(
                              color: Color(0xFFFF3E63),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          insight.readTime,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      insight.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF332B2C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insight.summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, Insight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArticleDetailView(insightId: insight.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  insight.coverImage,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    width: 80,
                    color: const Color(0xFFFFE5EC),
                    child: const Icon(Icons.image, size: 24, color: Colors.pink),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.category,
                      style: const TextStyle(
                        color: Color(0xFFFF3E63),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF332B2C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insight.readTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_outline, color: Color(0xFFFF3E63), size: 20),
                onPressed: () {
                  context.read<FavoritesViewModel>().removeFavorite(insight.id, ContentType.article);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Toggled Favorite status! 🌸")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunitySpotlightSection(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('community_box').listenable(),
      builder: (context, Box box, _) {
        final discussions = box.keys
            .where((k) => k.toString().startsWith('disc_'))
            .map((k) => Discussion.fromMap(Map<String, dynamic>.from(box.get(k))))
            .where((e) => !e.isDeleted)
            .toList();

        if (discussions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text("No discussions yet. 🌸", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          );
        }

        // Sort by trending criteria
        discussions.sort((a, b) => (b.views + b.likes + b.repliesCount).compareTo(a.views + a.likes + a.repliesCount));

        return SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: discussions.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final item = discussions[index];
              final badgeText = index == 0 ? "Trending" : "Hot";

              return Container(
                width: MediaQuery.of(context).size.width * 0.45,
                margin: const EdgeInsets.only(right: 12, bottom: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DiscussionDetailView(discussionId: item.id)),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.chat_bubble_outline, size: 10, color: Colors.deepPurple),
                              SizedBox(width: 4),
                              Text(
                                "Discussion",
                                style: TextStyle(fontSize: 9, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0E6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(fontSize: 8, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF332B2C),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${item.repliesCount} replies",
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
