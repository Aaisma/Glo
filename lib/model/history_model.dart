import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final List<String> content;
  final String details;
  final String? imageUrl;
  final String? relatedId;
  final String? relatedCollection;
  final DateTime date;
  final IconData icon;

  const HistoryModel({
    required this.id,
    this.userId = '',
    required this.type,
    required this.title,
    required this.content,
    required this.details,
    this.imageUrl,
    this.relatedId,
    this.relatedCollection,
    required this.date,
    required this.icon,
  });

  factory HistoryModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return HistoryModel(
      id: id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      content: List<String>.from(data['content'] ?? []),
      details: data['details'] ?? '',
      imageUrl: data['imageUrl'],
      relatedId: data['relatedId'],
      relatedCollection: data['relatedCollection'],
      date: _dateFromFirestore(data['date']),
      icon: _iconFromType(data['type']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'content': content,
      'details': details,
      'imageUrl': imageUrl,
      'relatedId': relatedId,
      'relatedCollection': relatedCollection,
      'date': Timestamp.fromDate(date),
    };
  }

  static DateTime _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
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