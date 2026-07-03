import 'package:flutter/material.dart';

class HistoryModel {
  final String id;
  final String type;
  final String title;
  final List<String> content;
  final String details;
  final DateTime date;
  final IconData icon;

  const HistoryModel({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.details,
    required this.date,
    required this.icon,
  });

  factory HistoryModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return HistoryModel(
      id: id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      content: List<String>.from(data['content'] ?? []),
      details: data['details'] ?? '',
      date: data['date'] == null
          ? DateTime.now()
          : DateTime.parse(data['date']),
      icon: _iconFromType(data['type']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'details': details,
      'date': date.toIso8601String(),
    };
  }

  static IconData _iconFromType(String? type) {
    switch (type) {
      case 'medication':
        return Icons.medication_outlined;

      case 'visit':
        return Icons.local_hospital_outlined;

      case 'cycle':
        return Icons.calendar_month_outlined;

      case 'acne':
        return Icons.face_retouching_natural_outlined;

      case 'mood':
        return Icons.mood_outlined;

      case 'journal':
        return Icons.menu_book_outlined;

      default:
        return Icons.history;
    }
  }
}