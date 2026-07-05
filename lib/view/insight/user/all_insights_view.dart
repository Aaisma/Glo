import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/ayd_colour.dart';
import '../../../viewmodel/insight_view_model.dart';
import 'article_detail_view.dart';

import 'package:timeago/timeago.dart' as timeago;

class AllInsightsView extends StatefulWidget {
  const AllInsightsView({super.key});

  @override
  State<AllInsightsView> createState() => _AllInsightsViewState();
}

class _AllInsightsViewState extends State<AllInsightsView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<InsightsFeedViewModel>();
      vm.setSearchQuery('');
      vm.loadFeed(isRefresh: true);
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
      context.read<InsightsFeedViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "All Articles",
          style: TextStyle(
            color: AydColors.insightButton,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<InsightsFeedViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              _buildSearchBar(viewModel),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AydColors.insightButton))
                    : viewModel.error != null
                        ? Center(child: Text("Error: ${viewModel.error}", style: const TextStyle(color: Colors.red)))
                        : viewModel.latestInsights.isEmpty
                            ? const Center(child: Text("No articles found. 🌸", style: TextStyle(color: Colors.grey)))
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                itemCount: viewModel.latestInsights.length + (viewModel.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == viewModel.latestInsights.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(color: AydColors.insightButton),
                                      ),
                                    );
                                  }
                                  final insight = viewModel.latestInsights[index];
                                  return _buildInsightCard(insight);
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(InsightsFeedViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: (val) {
            viewModel.setSearchQuery(val);
          },
          decoration: InputDecoration(
            hintText: "Search articles...",
            hintStyle: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: 15,
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 20),
                    onPressed: () {
                      _searchController.clear();
                      viewModel.setSearchQuery('');
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildInsightCard(dynamic item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ArticleDetailView(insightId: item.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: Image.asset(
                item.coverImage,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category,
                      style: const TextStyle(
                        color: AydColors.insightButton,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(
                          timeago.format(item.publishedAt ?? item.createdAt),
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.remove_red_eye_outlined, size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(
                          "${item.views}",
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
