import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../../viewmodel/community_view_model.dart';
import '../../../model/community_models.dart';
import '../../../model/shared_models.dart';
import '../../../repo/community_repo.dart';
import '../../../repo/community_moderation_repo.dart';
import '../../../constants/ayd_colour.dart';
import '../../../viewmodel/user_viewmodel.dart';
import 'edit_poll_view.dart';

class PollDetailView extends StatefulWidget {
  final String pollId;
  const PollDetailView({super.key, required this.pollId});

  @override
  State<PollDetailView> createState() => _PollDetailViewState();
}

class _PollDetailViewState extends State<PollDetailView> {
  bool _isLoading = true;
  CommunityPoll? _poll;
  List<CommunityPoll> _relatedPolls = [];
  StreamSubscription<CommunityPoll?>? _pollSubscription;

  // Tracked separately from `_poll!.userVotedOption` because that field lives
  // on the shared poll document and is never actually written by votePoll() —
  // relying on it caused the "voted" state to reset whenever the poll stream
  // pushed an update (e.g. right after voting).
  String? _userVotedOption;

  @override
  void initState() {
    super.initState();
    _loadPollData();
    _subscribeToPoll();
  }

  @override
  void dispose() {
    _pollSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToPoll() {
    final repo = context.read<CommunityRepo>();
    _pollSubscription = repo.getPollStream(widget.pollId).listen((poll) {
      if (mounted && poll != null) {
        setState(() {
          _poll = poll;
        });
      }
    });
  }

  Future<void> _loadPollData() async {
    setState(() => _isLoading = true);
    final repo = context.read<CommunityRepo>();
    await repo.addPollView(widget.pollId);
    final poll = await repo.getPollById(widget.pollId);
    final allPolls = await repo.getAllAdminPolls();
    final userVote = await repo.getUserVoteForPoll(widget.pollId);

    if (mounted) {
      setState(() {
        _poll = poll;
        _relatedPolls = allPolls.where((p) => p.id != widget.pollId && !p.isDeleted).toList();
        _userVotedOption = userVote;
        _isLoading = false;
      });
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AydColors.communityCardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Report Poll", style: TextStyle(fontWeight: FontWeight.bold, color: AydColors.communityButton)),
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
                  final modRepo = context.read<CommunityModerationRepo>();
                  if (_poll != null) {
                    await modRepo.reportContent(
                      contentId: _poll!.id,
                      contentType: ContentType.poll,
                      title: _poll!.question,
                      authorName: _poll!.username,
                      contentSnippet: _poll!.question,
                      reason: reason,
                    );
                  }
                  if (!context.mounted) return;
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Thank you for your report. The content has been sent for moderation. 💙")),
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

  Future<void> _handleVote(String option) async {
    if (_poll == null || _userVotedOption != null) return;
    final repo = context.read<CommunityRepo>();

    setState(() {
      _userVotedOption = option;
      _poll = _poll!.copyWith(
        totalVotes: _poll!.totalVotes + 1,
        options: {
          ..._poll!.options,
          option: (_poll!.options[option] ?? 0) + 1,
        },
      );
    });

    await repo.votePoll(_poll!.id, option);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _poll == null) {
      return const Scaffold(
        backgroundColor: AydColors.communityCardBackground,
        body: Center(child: CircularProgressIndicator(color: AydColors.communityButton)),
      );
    }

    final hasVoted = _userVotedOption != null;
    final formattedDate = DateFormat('MMMM dd, yyyy').format(_poll!.createdAt);

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
          title: const Text(
            "Poll Detail",
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
              onSelected: (value) async {
                if (value == 'hide') {
                  final modRepo = context.read<CommunityModerationRepo>();
                  final repo = context.read<CommunityRepo>();

                  await repo.hidePoll(_poll!.id);
                  await modRepo.recordHiddenContent(
                    contentId: _poll!.id,
                    contentType: ContentType.poll,
                    title: _poll!.question,
                    authorName: _poll!.username,
                    contentSnippet: _poll!.question,
                  );

                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Poll hidden. 🌸")),
                  );
                } else if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditPollView(pollId: _poll!.id)),
                  ).then((_) {
                    setState(() { _isLoading = true; });
                    _loadPollData();
                  });
                } else if (value == 'delete') {
                  final userVM = context.read<UserViewModel>();
                  if (userVM.user != null) {
                    await context.read<MyPostsViewModel>().deletePoll(_poll!.id, userVM.user!.id);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                } else if (value == 'report') {
                  _showReportDialog(context);
                }
              },
              icon: const Icon(Icons.more_vert, color: Color(0xFF332B2C)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) {
                final userVM = context.read<UserViewModel>();
                final isOwner = userVM.user != null && _poll!.userId == userVM.user!.id;

                return [
                  if (isOwner)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: AydColors.communityButton, size: 20),
                          SizedBox(width: 8),
                          Text("Edit Poll", style: TextStyle(color: AydColors.communityButton)),
                        ],
                      ),
                    ),
                  if (isOwner)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          SizedBox(width: 8),
                          Text("Delete Poll", style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  if (!isOwner)
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
                  if (!isOwner)
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
                ];
              },
            ),
          ],
        ),
        body: SafeArea(
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
                        color: Colors.black.withValues(alpha:0.01),
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
                            backgroundColor: const Color(0xFFE3F2FD),
                            child: Icon(
                              _poll!.isAnonymous ? Icons.security : Icons.person,
                              size: 18,
                              color: AydColors.communityButton,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _poll!.isAnonymous ? "Anonymous User" : "@${_poll!.username}",
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "POLL",
                              style: TextStyle(
                                color: AydColors.communityButton,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _poll!.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF332B2C),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${_poll!.totalVotes} votes • Public Poll",
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      // Options
                      ..._poll!.options.keys.map((option) {
                        final votes = _poll!.options[option] ?? 0;
                        final double percent = _poll!.totalVotes > 0 ? (votes / _poll!.totalVotes) : 0;
                        final isSelected = _userVotedOption == option;

                        return GestureDetector(
                          onTap: () => _handleVote(option),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AydColors.communityButton : Colors.grey.shade100,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // Animated progress fill
                                if (hasVoted)
                                  FractionallySizedBox(
                                    widthFactor: percent,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AydColors.communityButton.withValues(alpha: 0.4)
                                            : AydColors.communityButton.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),

                                // Text content
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: const Color(0xFF332B2C),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (hasVoted)
                                        Text(
                                          "${(percent * 100).toStringAsFixed(0)}%",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? AydColors.communityButton : Colors.black54,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      if (hasVoted)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: AydColors.communityButton.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AydColors.communityButton.withValues(alpha: 0.1)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: AydColors.communityButton, size: 20),
                              SizedBox(width: 12),
                              Text(
                                "You've voted for this poll",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Related Polls Section
                if (_relatedPolls.isNotEmpty) ...[
                  const Text(
                    "Related Polls",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF332B2C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _relatedPolls.length.clamp(0, 3),
                    itemBuilder: (context, index) {
                      final item = _relatedPolls[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(
                            item.question,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => PollDetailView(pollId: item.id)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}