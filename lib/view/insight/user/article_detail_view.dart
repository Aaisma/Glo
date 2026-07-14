import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/insight_view_model.dart';
import '../../../model/insight_models.dart';
import '../../../model/community_models.dart';
import 'all_insights_view.dart';

class ArticleDetailView extends StatefulWidget {
  final String insightId;
  const ArticleDetailView({super.key, required this.insightId});

  @override
  State<ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<ArticleDetailView> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleDetailViewModel>().loadDetail(widget.insightId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
                  if(!mounted) return;
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
    final accentColor = const Color(0xFFFF3E63);

    if (viewModel.isLoading || viewModel.insight == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF6F8),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1))),
      );
    }

    final insight = viewModel.insight!;
    final formattedDate = insight.updatedAt != null
        ? "Edited in ${DateFormat('MMMM dd, yyyy').format(insight.updatedAt!)}"
        : (insight.publishedAt != null
            ? DateFormat('MMMM dd, yyyy').format(insight.publishedAt!)
            : DateFormat('MMMM dd, yyyy').format(insight.createdAt));

    if (insight.isDeleted || insight.status == InsightStatus.archived) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF6F8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF332B2C)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text(
            "This content has been archived or deleted.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/feed/insight_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                    errorBuilder: (_, _, _) => Container(
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

                    // Comments
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          "${insight.commentsCount}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                  ],
                ),
              ),

              const Divider(height: 40, indent: 20, endIndent: 20),

              // Related Articles Section
              if (viewModel.relatedInsights.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Related Articles",
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
                            MaterialPageRoute(builder: (_) => const AllInsightsView()),
                          );
                        },
                        child: const Text(
                          "See all >",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
              // Comments Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Comments (${insight.commentsCount})",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF332B2C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              if (viewModel.comments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: Center(
                    child: Text(
                      "No comments yet. Be the first to comment! 🌸",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.comments.length,
                  itemBuilder: (context, index) {
                    final comment = viewModel.comments[index];
                    if (comment.isDeleted) return const SizedBox.shrink();
                    return _buildCommentCard(context, comment, viewModel, accentColor);
                  },
                ),
                
              const SizedBox(height: 30),
              ],
            ]),
          ),
        ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6F8),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: "Add a comment...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: accentColor),
              onPressed: () async {
                final text = _commentController.text.trim();
                if (text.isNotEmpty) {
                  await viewModel.addComment(text);
                  _commentController.clear();
                  if (!context.mounted) return;
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Comment posted! 🌸")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildCommentCard(
    BuildContext context,
    InsightComment comment,
    ArticleDetailViewModel vm,
    Color favColor,
  ) {
    final formattedTime = DateFormat('MMM dd, hh:mm a').format(comment.createdAt);
    final isLiked = vm.isCommentLiked(comment.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFFFD6E6),
            child: Icon(Icons.person, size: 14, color: favColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "@${comment.username}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF332B2C)),
                    ),
                    Text(
                      formattedTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF332B2C), height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => vm.likeComment(comment.id),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: isLiked ? favColor : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${comment.likes}",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
                errorBuilder: (_, _, _) => Container(height: 80, color: const Color(0xFFFFE5EC)),
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
