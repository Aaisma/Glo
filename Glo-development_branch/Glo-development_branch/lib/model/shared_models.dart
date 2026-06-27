import 'package:cloud_firestore/cloud_firestore.dart';

enum ContentType { article, poll, discussion }

class HiddenContent {
  final String userId;
  final String contentId;
  final ContentType type;

  HiddenContent({
    required this.userId,
    required this.contentId,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'contentId': contentId,
      'type': type.name,
    };
  }

  factory HiddenContent.fromMap(Map<String, dynamic> map) {
    return HiddenContent(
      userId: map['userId'] ?? '',
      contentId: map['contentId'] ?? '',
      type: ContentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ContentType.article,
      ),
    );
  }
}

enum FavoriteType { article, discussion, poll }

class FavoriteItem {
  final String id;
  final String contentId;
  final FavoriteType type;
  final DateTime savedAt;

  FavoriteItem({
    required this.id,
    required this.contentId,
    required this.type,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contentId': contentId,
      'type': type.name,
      'savedAt': savedAt,
    };
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      id: map['id'] ?? '',
      contentId: map['contentId'] ?? '',
      type: FavoriteType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FavoriteType.article,
      ),
      savedAt: map['savedAt'] is Timestamp 
          ? (map['savedAt'] as Timestamp).toDate() 
          : DateTime.parse(map['savedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

enum DraftType {
  insightArticle,
  insightPoll,
  discussion,
  communityPoll,
}

class DraftItem {
  final String id;
  final DraftType type;
  final Map<String, dynamic> content;
  final DateTime updatedAt;

  DraftItem({
    required this.id,
    required this.type,
    required this.content,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'updatedAt': updatedAt,
    };
  }

  factory DraftItem.fromMap(Map<String, dynamic> map) {
    return DraftItem(
      id: map['id'] ?? '',
      type: DraftType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DraftType.insightArticle,
      ),
      content: Map<String, dynamic>.from(map['content'] ?? {}),
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ArticleAnalytics {
  final int views;
  final int likes;
  final int saves;
  final int shares;

  ArticleAnalytics({
    this.views = 0,
    this.likes = 0,
    this.saves = 0,
    this.shares = 0,
  });
}

class DiscussionAnalytics {
  final int views;
  final int likes;
  final int replies;

  DiscussionAnalytics({
    this.views = 0,
    this.likes = 0,
    this.replies = 0,
  });
}

class PollAnalytics {
  final int views;
  final int votes;

  PollAnalytics({
    this.views = 0,
    this.votes = 0,
  });
}
