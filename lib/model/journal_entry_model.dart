import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntryModel {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String content;
  final DateTime createdAt;
  final String mood;
  final String emoji;
  final bool isFavorite;
  final String category; // 'regular', 'gratitude', 'future_letter', 'self_care', 'activity', 'reflection'
  final DateTime? unlockDate;

  JournalEntryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.mood,
    required this.emoji,
    this.isFavorite = false,
    this.category = 'regular',
    this.unlockDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'mood': mood,
      'emoji': emoji,
      'isFavorite': isFavorite,
      'category': category,
      'unlockDate': unlockDate != null ? Timestamp.fromDate(unlockDate!) : null,
    };
  }

  factory JournalEntryModel.fromMap(Map<String, dynamic> map) {
    return JournalEntryModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mood: map['mood'] ?? 'Calm',
      emoji: map['emoji'] ?? '😊',
      isFavorite: map['isFavorite'] ?? false,
      category: map['category'] ?? 'regular',
      unlockDate: (map['unlockDate'] as Timestamp?)?.toDate(),
    );
  }

  JournalEntryModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? title,
    String? content,
    DateTime? createdAt,
    String? mood,
    String? emoji,
    bool? isFavorite,
    String? category,
    DateTime? unlockDate,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      mood: mood ?? this.mood,
      emoji: emoji ?? this.emoji,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      unlockDate: unlockDate ?? this.unlockDate,
    );
  }
}
