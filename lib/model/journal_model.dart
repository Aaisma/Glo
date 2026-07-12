import 'package:cloud_firestore/cloud_firestore.dart';

class JournalModel {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String content;
  final String mood;
  final String emoji;
  final DateTime createdAt;
  final bool isFavorite;
  final String category; // 'regular', 'gratitude', 'future_letter', 'self_care', 'activity'
  final DateTime? unlockDate;

  JournalModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.content,
    required this.mood,
    required this.emoji,
    required this.createdAt,
    this.isFavorite = false,
    this.category = 'regular',
    this.unlockDate,
  });

  JournalModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? title,
    String? content,
    String? mood,
    String? emoji,
    DateTime? createdAt,
    bool? isFavorite,
    String? category,
    DateTime? unlockDate,
  }) {
    return JournalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      unlockDate: unlockDate ?? this.unlockDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'content': content,
      'mood': mood,
      'emoji': emoji,
      'createdAt': Timestamp.fromDate(createdAt),
      'isFavorite': isFavorite,
      'category': category,
      'unlockDate': unlockDate != null ? Timestamp.fromDate(unlockDate!) : null,
    };
  }

  factory JournalModel.fromMap(Map<String, dynamic> map) {
    return JournalModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      mood: map['mood'] ?? '',
      emoji: map['emoji'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFavorite: map['isFavorite'] ?? false,
      category: map['category'] ?? 'regular',
      unlockDate: (map['unlockDate'] as Timestamp?)?.toDate(),
    );
  }
}
