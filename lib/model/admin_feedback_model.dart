import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFeedbackModel {
  final String? id;
  final String userId;
  final String userName;
  final String userEmail;
  final String category;
  final String type;
  final String message;
  final int ratingIndex;
  final DateTime timestamp;
  final String status;
  final String device;
  final String appVersion;

  AdminFeedbackModel({
    this.id,
    required this.userId,
    this.userName = 'Anonymous',
    this.userEmail = 'N/A',
    required this.category,
    required this.type,
    required this.message,
    required this.ratingIndex,
    required this.timestamp,
    this.status = 'New',
    this.device = 'Unknown',
    this.appVersion = '1.0.0',
  });

  double get overallScore => (ratingIndex + 1).toDouble();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'category': category,
      'type': type,
      'message': message,
      'rating_index': ratingIndex,
      'timestamp': timestamp,
      'status': status,
      'device': device,
      'appVersion': appVersion,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory AdminFeedbackModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return AdminFeedbackModel(
      id: docId,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userEmail: json['userEmail'] ?? 'N/A',
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      ratingIndex: json['rating_index'] ?? -1,
      timestamp: _parseTimestamp(json['timestamp']),
      status: json['status'] ?? 'New',
      device: json['device'] ?? 'Unknown',
      appVersion: json['appVersion'] ?? '1.0.0',
    );
  }

  factory AdminFeedbackModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminFeedbackModel.fromJson(map, docId: id);
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  AdminFeedbackModel copyWith({String? status}) {
    return AdminFeedbackModel(
      id: id,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      category: category,
      type: type,
      message: message,
      ratingIndex: ratingIndex,
      timestamp: timestamp,
      status: status ?? this.status,
      device: device,
      appVersion: appVersion,
    );
  }
}
