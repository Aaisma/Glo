import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String? id;
  final String category;
  final String type;
  final String message;
  final int ratingIndex;
  final DateTime timestamp;
  final String status;

  FeedbackModel({
    this.id,
    required this.category,
    required this.type,
    required this.message,
    required this.ratingIndex,
    required this.timestamp,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'type': type,
      'message': message,
      'rating_index': ratingIndex,
      'timestamp': timestamp,
      'status': status,
    };
  }

  factory FeedbackModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return FeedbackModel(
      id: docId,
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      ratingIndex: json['rating_index'] ?? -1,
      timestamp: _parseTimestamp(json['timestamp']),
      status: json['status'] ?? 'New',
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is DateTime) {
      return value;
    }
    try {
      return value.toDate();
    } catch (_) {
      return DateTime.now();
    }
  }
}