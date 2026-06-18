import 'package:hive/hive.dart';
import '../model/community_models.dart';
import '../model/shared_models.dart';
import 'community_repo.dart';

class CommunityRepoImpl implements CommunityRepo {
  final Box _communityBox;
  final Box _draftsBox;

  CommunityRepoImpl({Box? communityBox, Box? draftsBox})
      : _communityBox = communityBox ?? Hive.box('community_box'),
        _draftsBox = draftsBox ?? Hive.box('drafts_box') {
    _initMockCategories();
    _initMockData();
  }

  void _initMockCategories() {
    if (!_communityBox.containsKey('cat_1')) {
      final categories = [
        CommunityCategory(id: 'cat_1', name: 'Mental Health', color: '#F0E6FF'),
        CommunityCategory(id: 'cat_2', name: 'Self-Care', color: '#FFE5EC'),
        CommunityCategory(id: 'cat_3', name: 'Relationships', color: '#E3F2FD'),
        CommunityCategory(id: 'cat_4', name: 'Lifestyle', color: '#FFF2F5'),
      ];
      for (var cat in categories) {
        _communityBox.put(cat.id, cat.toMap());
      }
    }
  }

  void _initMockData() {
    // Check if the mock discussions or polls are populated
    if (!_communityBox.containsKey('disc_1')) {
      final now = DateTime.now();

      // Mock discussions
      final d1 = Discussion(
        id: 'disc_1',
        title: "What's one habit that has changed your life for the better?",
        content: "For me, it is waking up at 6 AM and reading for 30 minutes. It gives me a calm start before the day gets busy. What about you guys?",
        username: 'Priya',
        isAnonymous: false,
        categoryId: 'cat_1',
        views: 180,
        likes: 24,
        repliesCount: 2,
        createdAt: now.subtract(const Duration(hours: 2)),
        replies: [
          DiscussionReply(
            id: 'rep_1',
            discussionId: 'disc_1',
            username: 'Leah',
            content: 'For me, it\'s morning journaling. It helps me start the day with clarity and gratitude.',
            likes: 12,
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
          DiscussionReply(
            id: 'rep_2',
            discussionId: 'disc_1',
            username: 'Anu',
            content: 'Drinking more water and sleeping on time! Game changer.',
            likes: 7,
            createdAt: now.subtract(const Duration(minutes: 45)),
          ),
        ],
      );

      final d2 = Discussion(
        id: 'disc_2',
        title: "How do you stay motivated on days when you don't feel like it?",
        content: "Some days I just want to stay in bed all day. How do you push through that mental block and get things done?",
        username: 'Maya',
        isAnonymous: false,
        categoryId: 'cat_2',
        views: 140,
        likes: 18,
        repliesCount: 0,
        createdAt: now.subtract(const Duration(hours: 5)),
        replies: [],
      );

      final d3 = Discussion(
        id: 'disc_3',
        title: "Tips for building healthy relationships?",
        content: "We often talk about boundaries, but what are other concrete tips to maintain trust and empathy over time?",
        username: 'Neha',
        isAnonymous: false,
        categoryId: 'cat_3',
        views: 160,
        likes: 16,
        repliesCount: 1,
        createdAt: now.subtract(const Duration(hours: 3)),
        replies: [
          DiscussionReply(
            id: 'rep_4',
            discussionId: 'disc_3',
            username: 'Maya',
            content: 'Moving my body daily has improved my mood so much.',
            likes: 5,
            createdAt: now.subtract(const Duration(minutes: 30)),
          ),
        ],
      );

      // Mock Polls
      final p1 = CommunityPoll(
        id: 'poll_1',
        question: 'If eligible for a work-from-home day, what do you prefer most?',
        options: {
          'Focus time with no meetings': 56,
          'A balance of meetings and deep work': 37,
          'Flexible schedule': 19,
          'Spending more time with family': 9,
          'Other (comment below)': 3,
        },
        categoryId: 'cat_1',
        totalVotes: 124,
        views: 310,
        shares: 12,
        createdAt: now.subtract(const Duration(days: 1)),
        createdBy: 'Anu',
      );

      _communityBox.put('disc_1', d1.toMap());
      _communityBox.put('disc_2', d2.toMap());
      _communityBox.put('disc_3', d3.toMap());
      _communityBox.put('poll_1', p1.toMap());
    }
  }

  @override
  @override
  Future<List<CommunityCategory>> getCategories() async {
    return _communityBox.values
        .where((e) {
          if (e is! Map) return false;
          final map = Map<String, dynamic>.from(e);
          return map.containsKey('color') && (map['isActive'] ?? true);
        })
        .map((e) => CommunityCategory.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<CommunityCategory?> getCategoryById(String id) async {
    final data = _communityBox.get(id);
    if (data == null) return null;
    return CommunityCategory.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<List<Discussion>> getDiscussions({
    required int page,
    required int limit,
    String? query,
    String? filter,
  }) async {
    final allItems = _communityBox.keys
        .where((key) => key.toString().startsWith('disc_'))
        .map((key) => Discussion.fromMap(Map<String, dynamic>.from(_communityBox.get(key))))
        .where((e) => !e.isDeleted)
        .toList();

    // Filtering chips
    var filtered = allItems;

    if (filter == 'Unanswered') {
      filtered = filtered.where((item) => item.repliesCount == 0).toList();
    } else if (filter == 'Following') {
      return []; // Return empty for Following tab in Phase 1
    }

    // Sort by filter
    if (filter == 'Trending') {
      filtered.sort((a, b) => (b.views + b.likes + b.repliesCount).compareTo(a.views + a.likes + a.repliesCount));
    } else {
      // Default / Recent
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered
          .where((e) => e.title.toLowerCase().contains(q) || e.content.toLowerCase().contains(q))
          .toList();
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) return [];
    final endIndex = (startIndex + limit) > filtered.length ? filtered.length : (startIndex + limit);
    return filtered.sublist(startIndex, endIndex);
  }

  @override
  Future<Discussion?> getDiscussionById(String id) async {
    final data = _communityBox.get(id);
    if (data == null) return null;
    final disc = Discussion.fromMap(Map<String, dynamic>.from(data));
    return disc.isDeleted ? null : disc;
  }

  @override
  Future<void> addDiscussion(Discussion discussion) async {
    await _communityBox.put(discussion.id, discussion.toMap());
  }

  @override
  Future<void> likeDiscussion(String id) async {
    final data = _communityBox.get(id);
    if (data != null) {
      final disc = Discussion.fromMap(Map<String, dynamic>.from(data));
      final likesBox = Hive.box('community_box');
      List<String> likedIds = List<String>.from(likesBox.get('liked_discussion_ids', defaultValue: <String>[]));
      
      int likesDiff = 0;
      if (likedIds.contains(id)) {
        likedIds.remove(id);
        likesDiff = -1;
      } else {
        likedIds.add(id);
        likesDiff = 1;
      }
      await likesBox.put('liked_discussion_ids', likedIds);

      final updated = disc.copyWith(likes: (disc.likes + likesDiff).clamp(0, 999999));
      await _communityBox.put(id, updated.toMap());
    }
  }

  @override
  Future<void> addReply(String discussionId, DiscussionReply reply) async {
    final data = _communityBox.get(discussionId);
    if (data != null) {
      final disc = Discussion.fromMap(Map<String, dynamic>.from(data));
      final replies = List<DiscussionReply>.from(disc.replies)..add(reply);
      final updated = disc.copyWith(
        replies: replies,
        repliesCount: replies.where((r) => !r.isDeleted).length,
      );
      await _communityBox.put(discussionId, updated.toMap());
    }
  }

  @override
  Future<void> likeReply(String discussionId, String replyId) async {
    final data = _communityBox.get(discussionId);
    if (data != null) {
      final disc = Discussion.fromMap(Map<String, dynamic>.from(data));
      final likesBox = Hive.box('community_box');
      List<String> likedIds = List<String>.from(likesBox.get('liked_reply_ids', defaultValue: <String>[]));
      
      int likesDiff = 0;
      if (likedIds.contains(replyId)) {
        likedIds.remove(replyId);
        likesDiff = -1;
      } else {
        likedIds.add(replyId);
        likesDiff = 1;
      }
      await likesBox.put('liked_reply_ids', likedIds);

      final updatedReplies = disc.replies.map((reply) {
        if (reply.id == replyId) {
          return reply.copyWith(likes: (reply.likes + likesDiff).clamp(0, 999999));
        }
        return reply;
      }).toList();

      final updated = disc.copyWith(replies: updatedReplies);
      await _communityBox.put(discussionId, updated.toMap());
    }
  }

  @override
  Future<List<CommunityPoll>> getPolls({required int page, required int limit}) async {
    final allItems = _communityBox.keys
        .where((key) => key.toString().startsWith('poll_'))
        .map((key) => CommunityPoll.fromMap(Map<String, dynamic>.from(_communityBox.get(key))))
        .where((e) => !e.isDeleted)
        .toList();

    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final startIndex = (page - 1) * limit;
    if (startIndex >= allItems.length) return [];
    final endIndex = (startIndex + limit) > allItems.length ? allItems.length : (startIndex + limit);
    return allItems.sublist(startIndex, endIndex);
  }

  @override
  Future<CommunityPoll?> getPollById(String id) async {
    final data = _communityBox.get(id);
    if (data == null) return null;
    final poll = CommunityPoll.fromMap(Map<String, dynamic>.from(data));
    return poll.isDeleted ? null : poll;
  }

  @override
  Future<void> addPoll(CommunityPoll poll) async {
    await _communityBox.put(poll.id, poll.toMap());
  }

  @override
  Future<void> votePoll(String pollId, String option) async {
    final data = _communityBox.get(pollId);
    if (data != null) {
      final poll = CommunityPoll.fromMap(Map<String, dynamic>.from(data));
      if (poll.userVotedOption != null) return;

      final updatedOptions = Map<String, int>.from(poll.options);
      updatedOptions[option] = (updatedOptions[option] ?? 0) + 1;

      final updated = poll.copyWith(
        options: updatedOptions,
        totalVotes: poll.totalVotes + 1,
        userVotedOption: option,
      );
      await _communityBox.put(pollId, updated.toMap());
    }
  }

  @override
  Future<void> sharePoll(String pollId) async {
    final data = _communityBox.get(pollId);
    if (data != null) {
      final poll = CommunityPoll.fromMap(Map<String, dynamic>.from(data));
      final updated = poll.copyWith(shares: poll.shares + 1);
      await _communityBox.put(pollId, updated.toMap());
    }
  }

  @override
  Future<void> saveDraft(DraftItem draft) async {
    await _draftsBox.put(draft.id, draft.toMap());
  }

  @override
  Future<DraftItem?> getDraft(String id) async {
    final data = _draftsBox.get(id);
    if (data == null) return null;
    return DraftItem.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> discardDraft(String id) async {
    await _draftsBox.delete(id);
  }

  @override
  Future<List<dynamic>> getCommunityFeed({
    required int page,
    required int limit,
    String? query,
    String? filter,
  }) async {
    if (filter == 'Following') {
      return []; // Phase 1 following filter stub returns empty
    }

    final discussions = await getDiscussions(page: 1, limit: 100, query: query, filter: filter);
    final polls = await getPolls(page: 1, limit: 100);

    final List<dynamic> feed = [];
    feed.addAll(discussions);
    feed.addAll(polls);

    // Apply sorting
    if (filter == 'Trending') {
      feed.sort((a, b) {
        final int aScore = (a is Discussion)
            ? (a.views + a.likes + a.repliesCount)
            : ((a as CommunityPoll).views + a.totalVotes + a.shares);
        final int bScore = (b is Discussion)
            ? (b.views + b.likes + b.repliesCount)
            : ((b as CommunityPoll).views + b.totalVotes + b.shares);
        return bScore.compareTo(aScore);
      });
    } else {
      feed.sort((a, b) {
        final DateTime aTime = (a is Discussion) ? a.createdAt : (a as CommunityPoll).createdAt;
        final DateTime bTime = (b is Discussion) ? b.createdAt : (b as CommunityPoll).createdAt;
        return bTime.compareTo(aTime);
      });
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= feed.length) return [];
    final endIndex = (startIndex + limit) > feed.length ? feed.length : (startIndex + limit);
    return feed.sublist(startIndex, endIndex);
  }

  @override
  Future<List<Discussion>> getAllAdminDiscussions() async {
    return _communityBox.keys
        .where((key) => key.toString().startsWith('disc_'))
        .map((key) => Discussion.fromMap(Map<String, dynamic>.from(_communityBox.get(key))))
        .toList();
  }

  @override
  Future<List<CommunityPoll>> getAllAdminPolls() async {
    return _communityBox.keys
        .where((key) => key.toString().startsWith('poll_'))
        .map((key) => CommunityPoll.fromMap(Map<String, dynamic>.from(_communityBox.get(key))))
        .toList();
  }

  @override
  Future<void> softDeleteDiscussion(String id) async {
    final data = _communityBox.get(id);
    if (data != null) {
      final disc = Discussion.fromMap(Map<String, dynamic>.from(data));
      final updated = disc.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
      );
      await _communityBox.put(id, updated.toMap());
    }
  }

  @override
  Future<void> softDeletePoll(String id) async {
    final data = _communityBox.get(id);
    if (data != null) {
      final poll = CommunityPoll.fromMap(Map<String, dynamic>.from(data));
      final updated = poll.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
      );
      await _communityBox.put(id, updated.toMap());
    }
  }

  @override
  Future<void> addDiscussionView(String id) async {
    final data = _communityBox.get(id);
    if (data != null) {
      final original = Discussion.fromMap(Map<String, dynamic>.from(data));
      final updated = original.copyWith(views: original.views + 1);
      await _communityBox.put(id, updated.toMap());
    }
  }

  @override
  Future<void> addPollView(String id) async {
    final data = _communityBox.get(id);
    if (data != null) {
      final original = CommunityPoll.fromMap(Map<String, dynamic>.from(data));
      final updated = original.copyWith(views: original.views + 1);
      await _communityBox.put(id, updated.toMap());
    }
  }
}
