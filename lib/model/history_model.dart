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

  /// Supports both:
  /// HistoryModel.fromMap(doc.id, doc.data())
  /// HistoryModel.fromMap(doc.data(), doc.id)
  factory HistoryModel.fromMap(
      dynamic firstArgument,
      dynamic secondArgument,
      ) {
    late final String documentId;
    late final Map<String, dynamic> data;

    if (firstArgument is String && secondArgument is Map) {
      documentId = firstArgument;
      data = Map<String, dynamic>.from(secondArgument);
    } else if (firstArgument is Map && secondArgument is String) {
      documentId = secondArgument;
      data = Map<String, dynamic>.from(firstArgument);
    } else {
      throw ArgumentError(
        'HistoryModel.fromMap requires a document ID and a data map.',
      );
    }

    final type = data['type']?.toString().trim().toLowerCase() ?? '';

    return HistoryModel(
      id: data['id']?.toString().trim().isNotEmpty == true
          ? data['id'].toString()
          : documentId,
      userId: data['userId']?.toString() ?? '',
      type: type,
      title: data['title']?.toString() ?? '',
      content: _contentFromFirestore(data['content']),
      details: data['details']?.toString() ?? '',
      imageUrl: _nullableString(data['imageUrl']),
      relatedId: _nullableString(data['relatedId']),
      relatedCollection: _nullableString(
        data['relatedCollection'],
      ),
      date: _dateFromFirestore(
        data['date'] ??
            data['createdAt'] ??
            data['updatedAt'],
      ),
      icon: _iconFromType(type),
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
      if (imageUrl != null && imageUrl!.trim().isNotEmpty)
        'imageUrl': imageUrl,
      if (relatedId != null && relatedId!.trim().isNotEmpty)
        'relatedId': relatedId,
      if (relatedCollection != null &&
          relatedCollection!.trim().isNotEmpty)
        'relatedCollection': relatedCollection,
      'date': Timestamp.fromDate(date),
    };
  }

  HistoryModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    List<String>? content,
    String? details,
    String? imageUrl,
    String? relatedId,
    String? relatedCollection,
    DateTime? date,
    IconData? icon,
  }) {
    return HistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      details: details ?? this.details,
      imageUrl: imageUrl ?? this.imageUrl,
      relatedId: relatedId ?? this.relatedId,
      relatedCollection:
      relatedCollection ?? this.relatedCollection,
      date: date ?? this.date,
      icon: icon ?? this.icon,
    );
  }

  static List<String> _contentFromFirestore(dynamic value) {
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList();
    }

    if (value != null && value.toString().trim().isNotEmpty) {
      return [value.toString()];
    }

    return [];
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  static DateTime _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return DateTime.now();
  }

  static IconData _iconFromType(String? type) {
    switch (type?.trim().toLowerCase()) {
      case 'medication':
        return Icons.medication_outlined;

      case 'visit':
      case 'health':
      case 'derma_visit':
        return Icons.local_hospital_outlined;

      case 'cycle':
        return Icons.calendar_month_outlined;

      case 'acne':
      case 'skin':
      case 'image':
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