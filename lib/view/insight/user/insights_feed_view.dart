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
                    child: Center(
                      child: Text(
                        "Insights Feed",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF3E63),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, color: Color(0xFF332B2C), size: 28),
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
                      color: Colors.black.withValues(alpha: 0.02),
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
                                        color: Color(0xFF8B5CF6),
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
                                        "See all >",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF8B5CF6),
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
    final categoriesData = [
      {'name': 'Trending', 'icon': Icons.local_fire_department_outlined, 'color': const Color(0xFFEAB308), 'bg': const Color(0xFFFEFCE8)},
      {'name': 'Health &\nWellness', 'icon': Icons.health_and_safety_outlined, 'color': const Color(0xFFFF3E63), 'bg': const Color(0xFFFFF0F3)},
      {'name': 'Lifestyle', 'icon': Icons.eco_outlined, 'color': const Color(0xFF22C55E), 'bg': const Color(0xFFF0FDF4)},
      {'name': 'Community', 'icon': Icons.people_outline, 'color': const Color(0xFFA855F7), 'bg': const Color(0xFFF3E8FF)},
      {'name': 'Expert\nInsights', 'icon': Icons.lightbulb_outline, 'color': const Color(0xFFF97316), 'bg': const Color(0xFFFFF7ED)},
    ];

    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoriesData.length,
        itemBuilder: (context, index) {
          final cat = categoriesData[index];
          final String catName = cat['name'] as String;
          final String queryName = catName.replaceAll('\n', ' ');
          final bool isSelected = viewModel.selectedCategory == queryName;

          return GestureDetector(
            onTap: () => viewModel.setCategory(queryName),
            child: Container(
              width: 76,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? (cat['color'] as Color).withValues(alpha: 0.15) : cat['bg'] as Color,
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? Border.all(color: cat['color'] as Color, width: 1.5) : Border.all(color: Colors.transparent),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    catName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cat['color'] as Color,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      height: 1.1,
                    ),
                  ),
                ],
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
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
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      insight.coverImage,
                      height: 120,
                      width: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        width: 110,
                        color: const Color(0xFFFFE5EC),
                        child: const Icon(Icons.image, size: 40, color: Colors.pink),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3E63),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "New",
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF332B2C),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insight.summary,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${insight.category} • ${insight.readTime}",
                            style: const TextStyle(
                              color: Color(0xFFFF3E63),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.bookmark_border, color: Colors.grey, size: 20),
                          onPressed: () {
                            context.read<FavoritesViewModel>().removeFavorite(insight.id, ContentType.article);
                          },
                        ),
                      ],
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
            color: Colors.black.withValues(alpha: 0.02),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      insight.coverImage,
                      height: 100,
                      width: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        width: 90,
                        color: const Color(0xFFFFE5EC),
                        child: const Icon(Icons.image, size: 30, color: Colors.pink),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3E63),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "New",
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF332B2C),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.summary,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${insight.category} • ${insight.readTime}",
                            style: const TextStyle(
                              color: Color(0xFF22C55E), // Making it match Lifestyle category dynamically would be better, but hardcoding green or keeping it pink for now. Using primary for consistency with mockup unless specified.
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.bookmark_outline, color: Colors.grey, size: 18),
                          onPressed: () {
                            context.read<FavoritesViewModel>().removeFavorite(insight.id, ContentType.article);
                          },
                        ),
                      ],
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
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: discussions.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final item = discussions[index];
              final badgeText = index == 0 ? "Trending" : "Recent";

              return Container(
                width: MediaQuery.of(context).size.width * 0.6,
                margin: const EdgeInsets.only(right: 12, bottom: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
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
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3E8FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_rounded,
                                size: 16,
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF332B2C),
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "${item.repliesCount} replies  •  $badgeText",
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
