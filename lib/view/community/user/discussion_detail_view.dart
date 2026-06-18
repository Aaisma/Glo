import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodel/community_view_model.dart';
import '../../model/community_models.dart';

class DiscussionDetailView extends StatefulWidget {
  final String discussionId;
  const DiscussionDetailView({super.key, required this.discussionId});

  @override
  State<DiscussionDetailView> createState() => _DiscussionDetailViewState();
}

class _DiscussionDetailViewState extends State<DiscussionDetailView> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscussionDetailViewModel>().loadDiscussion(widget.discussionId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showReportDialog(BuildContext context, DiscussionDetailViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Report Discussion", style: TextStyle(fontWeight: FontWeight.bold)),
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
    final viewModel = context.watch<DiscussionDetailViewModel>();
    final pinkTheme = const Color(0xFFFD8CA1);
    final accentColor = const Color(0xFFFF3E63);

    if (viewModel.isLoading || viewModel.discussion == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF6F8),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1))),
      );
    }

    final discussion = viewModel.discussion!;
    final formattedDate = DateFormat('MMMM dd, yyyy').format(discussion.createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      appBar: AppBar(
        title: const Text(
          "Discussion Detail",
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'hide') {
                viewModel.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Discussion hidden. 🌸")),
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Post Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFFFFE5EC),
                                child: Icon(
                                  discussion.isAnonymous ? Icons.security : Icons.person,
                                  size: 18,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      discussion.isAnonymous ? "Anonymous User" : "@${discussion.username}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            discussion.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF332B2C),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            discussion.content,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF332B2C),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              // Like Action
                              GestureDetector(
                                onTap: viewModel.like,
                                child: Row(
                                  children: [
                                    Icon(
                                      viewModel.isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: viewModel.isLiked ? accentColor : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${discussion.likes}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Row(
                                children: [
                                  const Icon(Icons.mode_comment_outlined, color: Colors.grey, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${discussion.repliesCount}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Row(
                                children: [
                                  const Icon(Icons.remove_red_eye_outlined, color: Colors.grey, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${discussion.views}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Replies header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Replies (${discussion.replies.where((r) => !r.isDeleted).length})",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF332B2C),
                          ),
                        ),
                        const Text(
                          "View all",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Replies list
                    if (discussion.replies.where((r) => !r.isDeleted).isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.0),
                        child: Center(
                          child: Text(
                            "No replies yet. Be the first to reply! 🌸",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: discussion.replies.length,
                        itemBuilder: (context, index) {
                          final reply = discussion.replies[index];
                          if (reply.isDeleted) return const SizedBox.shrink();
                          return _buildReplyCard(context, reply, viewModel, accentColor);
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Write reply compose bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                          hintText: "Add your reply...",
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
                        if (mounted) {
                          FocusScope.of(context).unfocus();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Reply posted! 🌸")),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(
    BuildContext context,
    DiscussionReply reply,
    DiscussionDetailViewModel vm,
    Color favColor,
  ) {
    final formattedTime = DateFormat('MMM dd, hh:mm a').format(reply.createdAt);
    final isLiked = vm.isReplyLiked(reply.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
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
                      "@${reply.username}",
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
                  reply.content,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF332B2C), height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => vm.likeReply(reply.id),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: isLiked ? favColor : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${reply.likes}",
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
}
