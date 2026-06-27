import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/insight_view_model.dart';
import '../../../model/insight_models.dart';
import '../../../model/community_models.dart';

class ArticleDetailView extends StatefulWidget {
  final String insightId;
  const ArticleDetailView({super.key, required this.insightId});

  @override
  State<ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<ArticleDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleDetailViewModel>().loadDetail(widget.insightId);
    });
  }

  @override
  void didUpdateWidget(covariant ArticleDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.insightId != widget.insightId) {
      context.read<ArticleDetailViewModel>().loadDetail(widget.insightId);
    }
  }

  void _showReportDialog(BuildContext context, ArticleDetailViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Report Post", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ModerationReason.values.map((reason) {
              String label = reason.name;
              if (reason == ModerationReason.inappropriateContent) {
                label = "Inappropriate Content";
              } else {
                label = label[0].toUpperCase() + label.substring(1);
              }

              return ListTile(
                title: Text(label),
                onTap: () async {
                  await viewModel.report(reason);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Thank you for your report. The content has been sent for moderation. 🌸")),
                  );
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ArticleDetailViewModel>();
    const pinkTheme = Color(0xFFFD8CA1);
    const accentColor = Color(0xFFFF3E63);

    if (viewModel.isLoading || viewModel.insight == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF6F8),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1))),
      );
    }

    final insight = viewModel.insight!;
    final formattedDate = insight.publishedAt != null
        ? DateFormat('MMMM dd, yyyy').format(insight.publishedAt!)
        : DateFormat('MMMM dd, yyyy').format(insight.createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF332B2C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'hide') {
                viewModel.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Article hidden. 🌸")),
                );
              } else if (value == 'report') {
                _showReportDialog(context, viewModel);
              }
            },
            icon: const Icon(Icons.more_vert, color: Color(0xFF332B2C)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'hide',
                child: Row(
                  children: [
                    Icon(Icons.visibility_off_outlined, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text("Hide Post"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report_outlined, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text("Report Post", style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5EC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        insight.category.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFFF3E63),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      insight.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF332B2C),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${insight.readTime} • $formattedDate",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Cover Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    insight.coverImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: const Color(0xFFFFE5EC),
                      child: const Icon(Icons.image, size: 50, color: Colors.pink),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Article Summary (Subtitle)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  insight.summary,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF332B2C),
                    height: 1.4,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),

              // Article Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  insight.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF332B2C),
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Social Actions Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    // Like Button
                    GestureDetector(
                      onTap: viewModel.like,
                      child: Row(
                        children: [
                          Icon(
                            viewModel.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: viewModel.isLiked ? accentColor : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${insight.likes}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Comments Placeholder/Mock Icon
                    const Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 22),
                        SizedBox(width: 6),
                        Text(
                          "24",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Save Button
                    GestureDetector(
                      onTap: viewModel.save,
                      child: Row(
                        children: [
                          Icon(
                            viewModel.isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: viewModel.isSaved ? accentColor : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Save",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Share Button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Link copied to clipboard! 🌸")),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.share_outlined, color: Colors.grey, size: 24),
                          SizedBox(width: 6),
                          Text(
                            "Share",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 40, indent: 20, endIndent: 20),

              // Related Articles Section
              if (viewModel.relatedInsights.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Related Articles",
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
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 170,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: viewModel.relatedInsights.length,
                    itemBuilder: (context, index) {
                      final rel = viewModel.relatedInsights[index];
                      return _buildRelatedCard(context, rel);
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedCard(BuildContext context, Insight rel) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ArticleDetailView(insightId: rel.id)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                rel.coverImage,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 80, color: const Color(0xFFFFE5EC)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rel.title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF332B2C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rel.readTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 9),
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
}
