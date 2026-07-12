import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../model/community_models.dart';
import '../../../model/shared_models.dart';
import '../../../repo/community_repo.dart';
import '../../../repo/community_moderation_repo.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPollData();
  }

  Future<void> _loadPollData() async {
    setState(() => _isLoading = true);
    final repo = context.read<CommunityRepo>();
    await repo.addPollView(widget.pollId);
    final poll = await repo.getPollById(widget.pollId);
    final allPolls = await repo.getAllAdminPolls();
    
    if (mounted) {
      setState(() {
        _poll = poll;
        _relatedPolls = allPolls.where((p) => p.id != widget.pollId && !p.isDeleted).toList();
        _isLoading = false;
      });
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Report Poll", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _handleVote(String option) async {
    if (_poll == null || _poll!.userVotedOption != null) return;
    final repo = context.read<CommunityRepo>();
    await repo.votePoll(_poll!.id, option);
    await _loadPollData();
  }

  @override
  Widget build(BuildContext context) {
    final pinkTheme = const Color(0xFFFD8CA1);
    final accentColor = const Color(0xFFFF3E63);

    if (_isLoading || _poll == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF6F8),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFD8CA1))),
      );
    }

    final hasVoted = _poll!.userVotedOption != null;

    if (_poll!.isDeleted) {
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
            "This poll has been archived or deleted.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

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
          "Poll Details",
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
                final hiddenBox = Hive.box('hidden_content_box');
                final hc = HiddenContent(
                  userId: 'user_active',
                  contentId: _poll!.id,
                  type: ContentType.poll,
                );
                await hiddenBox.put(_poll!.id, hc.toMap());
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Poll hidden. 🌸")),
                  );
              } else if (value == 'report') {
                _showReportDialog(context);
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "POLL OF THE DAY",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Question
              Text(
                _poll!.question,
                style: const TextStyle(
                  fontSize: 22,
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

              ..._poll!.options.keys.map((option) {
                final votes = _poll!.options[option] ?? 0;
                final double percent = _poll!.totalVotes > 0 ? (votes / _poll!.totalVotes) : 0;
                final isSelected = _poll!.userVotedOption == option;

                return GestureDetector(
                  onTap: () => _handleVote(option),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? accentColor : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated progress fill
                        if (hasVoted)
                          FractionallySizedBox(
                            widthFactor: percent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? pinkTheme.withValues(alpha: 0.3)
                                    : Colors.pink.shade50.withValues(alpha: 0.5),
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
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.bold,
                                    color: isSelected ? accentColor : Colors.black54,
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

              const SizedBox(height: 16),

              // Confirmation Banner
              if (hasVoted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6F8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: pinkTheme.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: accentColor),
                      const SizedBox(width: 12),
                      const Text(
                        "You've voted for this poll",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
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
                    fontSize: 18,
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
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.01),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          item.question,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C)),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 12),
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
    ));
  }
}
