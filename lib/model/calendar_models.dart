import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarNoteModel {
  final String id;
  final String userId;
  final String date;
  final String note;
  final DateTime createdAt;

  CalendarNoteModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'note': note,
      'createdAt': createdAt,
    };
  }

  factory CalendarNoteModel.fromMap(Map<String, dynamic> map, String docId) {
    return CalendarNoteModel(
      id: docId,
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      note: map['note'] ?? '',
      createdAt: map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

class CalendarTodoModel {
  final String id;
  final String userId;
  final String date;
  final String text;
  final bool isDone;
  final DateTime createdAt;

  CalendarTodoModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.text,
    this.isDone = false,
    required this.createdAt,
  });

  CalendarTodoModel copyWith({bool? isDone, String? text}) {
    return CalendarTodoModel(
      id: id,
      userId: userId,
      date: date,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'text': text,
      'isDone': isDone,
      'createdAt': createdAt,
    };
  }

  factory CalendarTodoModel.fromMap(Map<String, dynamic> map, String docId) {
    return CalendarTodoModel(
      id: docId,
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      text: map['text'] ?? '',
      isDone: map['isDone'] ?? false,
      createdAt: map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

class RoutineModel {
  final String id;
  final String userId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String emoji;
  final DateTime createdAt;

  RoutineModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.emoji,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'emoji': emoji,
      'createdAt': createdAt,
    };
  }

  factory RoutineModel.fromMap(Map<String, dynamic> map, String docId) {
    return RoutineModel(
      id: docId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      startTime: map['startTime'] is Timestamp ? (map['startTime'] as Timestamp).toDate() : DateTime.now(),
      endTime: map['endTime'] is Timestamp ? (map['endTime'] as Timestamp).toDate() : DateTime.now().add(const Duration(hours: 1)),
      emoji: map['emoji'] ?? '✨',
      createdAt: map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}