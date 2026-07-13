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
    DateTime parseDate(dynamic dateData) {
      if (dateData == null) return DateTime.now();
      if (dateData is Timestamp) return dateData.toDate();
      if (dateData is String) return DateTime.tryParse(dateData) ?? DateTime.now();
      return DateTime.now();
    }

    return JournalModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      title: map['title'] ?? map['prompt'] ?? '',
      content: map['content'] ?? map['text'] ?? '',
      mood: map['mood'] ?? '',
      emoji: map['emoji'] ?? '',
      createdAt: parseDate(map['createdAt']),
      isFavorite: map['isFavorite'] ?? false,
      category: map['category'] ?? 'regular',
      unlockDate: map['unlockDate'] != null ? parseDate(map['unlockDate']) : null,
    );
  }
}
