import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

enum InsightStatus { draft, published, scheduled, archived }

class Insight {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String coverImage;
  final String category;
  final String readTime;
  final InsightStatus status;
  final bool isFeatured;
  final bool isTrending;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String authorId;
  final int views;
  final int likes;
  final int saves;
  final int shares;
  final int commentsCount;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime? updatedAt;

  Insight({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.coverImage,
    required this.category,
    required this.readTime,
    required this.status,
    required this.isFeatured,
    required this.isTrending,
    required this.createdAt,
    this.publishedAt,
    required this.authorId,
    this.views = 0,
    this.likes = 0,
    this.saves = 0,
    this.shares = 0,
    this.commentsCount = 0,
    this.isDeleted = false,
    this.deletedAt,
    this.updatedAt,
  });

  Insight copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? coverImage,
    String? category,
    String? readTime,
    InsightStatus? status,
    bool? isFeatured,
    bool? isTrending,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? authorId,
    int? views,
    int? likes,
    int? saves,
    int? shares,
    int? commentsCount,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? updatedAt,
  }) {
    return Insight(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      coverImage: coverImage ?? this.coverImage,
      category: category ?? this.category,
      readTime: readTime ?? this.readTime,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      authorId: authorId ?? this.authorId,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      saves: saves ?? this.saves,
      shares: shares ?? this.shares,
      commentsCount: commentsCount ?? this.commentsCount,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'coverImage': coverImage,
      'category': category,
      'readTime': readTime,
      'status': status.name,
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'createdAt': createdAt,
      'publishedAt': publishedAt,
      'authorId': authorId,
      'views': views,
      'likes': likes,
      'saves': saves,
      'shares': shares,
      'commentsCount': commentsCount,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Insight.fromMap(Map<String, dynamic> map) {
    return Insight(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      content: map['content'] ?? '',
      coverImage: map['coverImage'] ?? '',
      category: map['category'] ?? '',
      readTime: map['readTime'] ?? '',
      status: InsightStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => InsightStatus.draft,
      ),
      isFeatured: map['isFeatured'] ?? false,
      isTrending: map['isTrending'] ?? false,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      publishedAt: map['publishedAt'] != null 
          ? (map['publishedAt'] is Timestamp ? (map['publishedAt'] as Timestamp).toDate() : DateTime.parse(map['publishedAt'])) 
          : null,
      authorId: map['authorId'] ?? '',
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      saves: map['saves'] ?? 0,
      shares: map['shares'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
      deletedAt: map['deletedAt'] != null 
          ? (map['deletedAt'] is Timestamp ? (map['deletedAt'] as Timestamp).toDate() : DateTime.parse(map['deletedAt'].toString())) 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] is Timestamp ? (map['updatedAt'] as Timestamp).toDate() : DateTime.parse(map['updatedAt'].toString())) 
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Insight.fromJson(String source) => Insight.fromMap(json.decode(source));
}

class InsightComment {
  final String id;
  final String insightId;
  final String username;
  final String content;
  final int likes;
  final DateTime createdAt;
  final bool isDeleted;

  InsightComment({
    required this.id,
    required this.insightId,
    required this.username,
    required this.content,
    this.likes = 0,
    required this.createdAt,
    this.isDeleted = false,
  });

  InsightComment copyWith({
    String? id,
    String? insightId,
    String? username,
    String? content,
    int? likes,
    DateTime? createdAt,
    bool? isDeleted,
  }) {
    return InsightComment(
      id: id ?? this.id,
      insightId: insightId ?? this.insightId,
      username: username ?? this.username,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'insightId': insightId,
      'username': username,
      'content': content,
      'likes': likes,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
    };
  }

  factory InsightComment.fromMap(Map<String, dynamic> map) {
    return InsightComment(
      id: map['id'] ?? '',
      insightId: map['insightId'] ?? '',
      username: map['username'] ?? '',
      content: map['content'] ?? '',
      likes: map['likes'] ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
