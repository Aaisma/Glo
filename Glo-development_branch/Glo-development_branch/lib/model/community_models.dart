import 'package:cloud_firestore/cloud_firestore.dart';
import 'shared_models.dart';

enum ModerationReason { spam, misinformation, harassment, inappropriateContent, other }

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
  final String username;
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
    required this.username,
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
    String? username,
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
      username: username ?? this.username,
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
      'username': username,
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
      username: map['username'] ?? '',
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
  final String username;
  final String content;
  final int likes;
  final DateTime createdAt;
  final bool isDeleted;
  final DateTime? deletedAt;

  DiscussionReply({
    required this.id,
    required this.discussionId,
    required this.username,
    required this.content,
    this.likes = 0,
    required this.createdAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  DiscussionReply copyWith({
    String? id,
    String? discussionId,
    String? username,
    String? content,
    int? likes,
    DateTime? createdAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return DiscussionReply(
      id: id ?? this.id,
      discussionId: discussionId ?? this.discussionId,
      username: username ?? this.username,
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
      'username': username,
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
      username: map['username'] ?? '',
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
  final String createdBy;
  final String? userVotedOption;
  final bool isDeleted;
  final DateTime? deletedAt;

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
    required this.createdBy,
    this.userVotedOption,
    this.isDeleted = false,
    this.deletedAt,
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
    String? createdBy,
    String? userVotedOption,
    bool? isDeleted,
    DateTime? deletedAt,
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
      createdBy: createdBy ?? this.createdBy,
      userVotedOption: userVotedOption ?? this.userVotedOption,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
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
      'createdBy': createdBy,
      'userVotedOption': userVotedOption,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
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
      createdBy: map['createdBy'] ?? '',
      userVotedOption: map['userVotedOption'],
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'] != null 
          ? (map['deletedAt'] is Timestamp ? (map['deletedAt'] as Timestamp).toDate() : DateTime.parse(map['deletedAt'])) 
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
