import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String desc;
  final String day;
  final String time;
  final String badge;
  final String icon;
  final bool unread;
  final DateTime createdAt; // Required for the 1-week auto-erasure filter

  NotificationModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.day,
    required this.time,
    required this.badge,
    required this.icon,
    required this.unread,
    required this.createdAt,
  });

  // 🔎 Factory to build NotificationModel from Firestore document
  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return NotificationModel(
      id: docId,
      title: data['title'] ?? '',
      desc: data['desc'] ?? '',
      day: data['day'] ?? '',
      time: data['time'] ?? '',
      badge: data['badge'] ?? '',
      icon: data['icon'] ?? '',
      unread: data['unread'] ?? true,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? desc,
    String? day,
    String? time,
    String? badge,
    String? icon,
    bool? unread,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      day: day ?? this.day,
      time: time ?? this.time,
      badge: badge ?? this.badge,
      icon: icon ?? this.icon,
      unread: unread ?? this.unread,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
