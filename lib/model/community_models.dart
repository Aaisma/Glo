import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_models.dart';

enum ModerationReason { spam, misinformation, harassment, inappropriateContent, other }
enum PollStatus { draft, scheduled, published }

class CommunityCategory {
  final String id;
  final String name;
  final String color;
  final bool isActive;

  CommunityCategory({
    required this.id,
    required this.name,
    required this.color,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'isActive': isActive,
    };
  }

  factory CommunityCategory.fromMap(Map<String, dynamic> map) {
    return CommunityCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      color: map['color'] ?? '#FD8CA1',
      isActive: map['isActive'] ?? true,
    );
  }
}

class Discussion {
  final String id;
  final String title;
  final String content;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final bool isAnonymous;
  final String categoryId;
  final int views;
  final int likes;
  final int repliesCount;
  final int reportsCount;
  final int hiddenCount;
  final DateTime createdAt;
  final List<DiscussionReply> replies;
  final bool isDeleted;
  final DateTime? deletedAt;

  Discussion({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.isAnonymous,
    required this.categoryId,
    this.views = 0,
    this.likes = 0,
    this.repliesCount = 0,
    this.reportsCount = 0,
    this.hiddenCount = 0,
    required this.createdAt,
    required this.replies,
    this.isDeleted = false,
    this.deletedAt,
  });

  Discussion copyWith({
    String? id,
    String? title,
    String? content,
    String? userId,
    String? username,
    String? profileImageUrl,
    bool? isAnonymous,
    String? categoryId,
    int? views,
    int? likes,
    int? repliesCount,
    int? reportsCount,
    int? hiddenCount,
    DateTime? createdAt,
    List<DiscussionReply>? replies,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Discussion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      categoryId: categoryId ?? this.categoryId,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      repliesCount: repliesCount ?? this.repliesCount,
      reportsCount: reportsCount ?? this.reportsCount,
      hiddenCount: hiddenCount ?? this.hiddenCount,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'isAnonymous': isAnonymous,
      'categoryId': categoryId,
      'views': views,
      'likes': likes,
      'repliesCount': repliesCount,
      'reportsCount': reportsCount,
      'hiddenCount': hiddenCount,
      'createdAt': createdAt,
      'replies': replies.map((x) => x.toMap()).toList(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
    };
  }

  factory Discussion.fromMap(Map<String, dynamic> map) {
    return Discussion(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      isAnonymous: map['isAnonymous'] ?? false,
      categoryId: map['categoryId'] ?? '',
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      repliesCount: map['repliesCount'] ?? 0,
      reportsCount: map['reportsCount'] ?? 0,
      hiddenCount: map['hiddenCount'] ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      replies: List<DiscussionReply>.from(
        (map['replies'] ?? []).map((x) => DiscussionReply.fromMap(x)),
      ),
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'] != null 
          ? (map['deletedAt'] is Timestamp ? (map['deletedAt'] as Timestamp).toDate() : DateTime.parse(map['deletedAt'])) 
          : null,
    );
  }
}

class DiscussionReply {
  final String id;
  final String discussionId;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final String content;
  final int likes;
  final DateTime createdAt;
  final bool isDeleted;
  final DateTime? deletedAt;

  DiscussionReply({
    required this.id,
    required this.discussionId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.content,
    this.likes = 0,
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  DiscussionReply copyWith({
    String? id,
    String? discussionId,
    String? userId,
    String? username,
    String? profileImageUrl,
    String? content,
    int? likes,
    DateTime? createdAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return DiscussionReply(
      id: id ?? this.id,
      discussionId: discussionId ?? this.discussionId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'discussionId': discussionId,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'content': content,
      'likes': likes,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
    };
  }

  factory DiscussionReply.fromMap(Map<String, dynamic> map) {
    return DiscussionReply(
      id: map['id'] ?? '',
      discussionId: map['discussionId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      content: map['content'] ?? '',
      likes: map['likes'] ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'] != null 
          ? (map['deletedAt'] is Timestamp ? (map['deletedAt'] as Timestamp).toDate() : DateTime.parse(map['deletedAt'])) 
          : null,
    );
  }
}

class CommunityPoll {
  final String id;
  final String question;
  final Map<String, int> options;
  final String categoryId;
  final int totalVotes;
  final int views;
  final int shares;
  final int reportsCount;
  final int hiddenCount;
  final DateTime createdAt;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final bool isAnonymous;
  final String? userVotedOption;
  final bool isDeleted;
  final DateTime? deletedAt;
  final PollStatus status;
  final DateTime? publishedAt;

  CommunityPoll({
    required this.id,
    required this.question,
    required this.options,
    required this.categoryId,
    this.totalVotes = 0,
    this.views = 0,
    this.shares = 0,
    this.reportsCount = 0,
    this.hiddenCount = 0,
    required this.createdAt,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    this.isAnonymous = false,
    this.userVotedOption,
    this.isDeleted = false,
    this.deletedAt,
    this.status = PollStatus.published,
    this.publishedAt,
  });

  CommunityPoll copyWith({
    String? id,
    String? question,
    Map<String, int>? options,
    String? categoryId,
    int? totalVotes,
    int? views,
    int? shares,
    int? reportsCount,
    int? hiddenCount,
    DateTime? createdAt,
    String? userId,
    String? username,
    String? profileImageUrl,
    bool? isAnonymous,
    String? userVotedOption,
    bool? isDeleted,
    DateTime? deletedAt,
    PollStatus? status,
    DateTime? publishedAt,
  }) {
    return CommunityPoll(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      categoryId: categoryId ?? this.categoryId,
      totalVotes: totalVotes ?? this.totalVotes,
      views: views ?? this.views,
      shares: shares ?? this.shares,
      reportsCount: reportsCount ?? this.reportsCount,
      hiddenCount: hiddenCount ?? this.hiddenCount,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      userVotedOption: userVotedOption ?? this.userVotedOption,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'categoryId': categoryId,
      'totalVotes': totalVotes,
      'views': views,
      'shares': shares,
      'reportsCount': reportsCount,
      'hiddenCount': hiddenCount,
      'createdAt': createdAt,
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'isAnonymous': isAnonymous,
      'userVotedOption': userVotedOption,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'status': status.name,
      'publishedAt': publishedAt,
    };
  }

  factory CommunityPoll.fromMap(Map<String, dynamic> map) {
    return CommunityPoll(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      options: Map<String, int>.from(map['options'] ?? {}),
      categoryId: map['categoryId'] ?? '',
      totalVotes: map['totalVotes'] ?? 0,
      views: map['views'] ?? 0,
      shares: map['shares'] ?? 0,
      reportsCount: map['reportsCount'] ?? 0,
      hiddenCount: map['hiddenCount'] ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      userId: map['userId'] ?? map['createdBy'] ?? '', // Fallback for old data
      username: map['username'] ?? map['createdBy'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      isAnonymous: map['isAnonymous'] ?? false,
      userVotedOption: map['userVotedOption'],
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'] != null 
          ? (map['deletedAt'] is Timestamp ? (map['deletedAt'] as Timestamp).toDate() : DateTime.parse(map['deletedAt'])) 
          : null,
      status: PollStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PollStatus.published,
      ),
      publishedAt: map['publishedAt'] != null
          ? (map['publishedAt'] is Timestamp ? (map['publishedAt'] as Timestamp).toDate() : DateTime.parse(map['publishedAt']))
          : null,
    );
  }
}

class ModerationItem {
  final String id;
  final String contentId;
  final ContentType contentType;
  final String title;
  final String authorName;
  final String contentSnippet;
  final List<ModerationReason> reasons;
  final int reportsCount;
  final int hiddenCount;
  final DateTime reportedAt;
  final bool isArchived;
  final bool isDeleted;

  ModerationItem({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.title,
    required this.authorName,
    required this.contentSnippet,
    required this.reasons,
    required this.reportsCount,
    required this.hiddenCount,
    required this.reportedAt,
    this.isArchived = false,
    this.isDeleted = false,
  });

  ModerationItem copyWith({
    String? id,
    String? contentId,
    ContentType? contentType,
    String? title,
    String? authorName,
    String? contentSnippet,
    List<ModerationReason>? reasons,
    int? reportsCount,
    int? hiddenCount,
    DateTime? reportedAt,
    bool? isArchived,
    bool? isDeleted,
  }) {
    return ModerationItem(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      contentSnippet: contentSnippet ?? this.contentSnippet,
      reasons: reasons ?? this.reasons,
      reportsCount: reportsCount ?? this.reportsCount,
      hiddenCount: hiddenCount ?? this.hiddenCount,
      reportedAt: reportedAt ?? this.reportedAt,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contentId': contentId,
      'contentType': contentType.name,
      'title': title,
      'authorName': authorName,
      'contentSnippet': contentSnippet,
      'reasons': reasons.map((x) => x.name).toList(),
      'reportsCount': reportsCount,
      'hiddenCount': hiddenCount,
      'reportedAt': reportedAt,
      'isArchived': isArchived,
      'isDeleted': isDeleted,
    };
  }

  factory ModerationItem.fromMap(Map<String, dynamic> map) {
    return ModerationItem(
      id: map['id'] ?? '',
      contentId: map['contentId'] ?? '',
      contentType: ContentType.values.firstWhere(
        (e) => e.name == map['contentType'],
        orElse: () => ContentType.article,
      ),
      title: map['title'] ?? '',
      authorName: map['authorName'] ?? '',
      contentSnippet: map['contentSnippet'] ?? '',
      reasons: List<ModerationReason>.from(
        (map['reasons'] ?? []).map(
          (x) => ModerationReason.values.firstWhere((e) => e.name == x, orElse: () => ModerationReason.other),
        ),
      ),
      reportsCount: map['reportsCount'] ?? 0,
      hiddenCount: map['hiddenCount'] ?? 0,
      reportedAt: map['reportedAt'] is Timestamp 
          ? (map['reportedAt'] as Timestamp).toDate() 
          : DateTime.parse(map['reportedAt'] ?? DateTime.now().toIso8601String()),
      isArchived: map['isArchived'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
