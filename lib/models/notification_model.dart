import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for all notification types
enum NotificationType {
  ovulation,
  medication,
  moodTracker,
  dermaVisit,
  period,
  periodLog,
  journal,
  water,
  acne,
}

/// Notification model class
class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? typeLabel;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.typeLabel,
  });

  /// Badge text for UI display
  String get badgeText {
    if (typeLabel != null) return typeLabel!;
    switch (type) {
      case NotificationType.ovulation: return 'Ovulation';
      case NotificationType.medication: return 'Medication';
      case NotificationType.moodTracker: return 'Mood Tracker';
      case NotificationType.dermaVisit: return 'Derma Visit';
      case NotificationType.period: return 'Period';
      case NotificationType.periodLog: return 'Period Log';
      case NotificationType.journal: return 'Journal';
      case NotificationType.water: return 'Water';
      case NotificationType.acne: return 'Acne';
    }
  }

  /// Convert Firestore document to NotificationModel
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      type: NotificationType.values.firstWhere(
            (e) => e.toString() == data['type'],
        orElse: () => NotificationType.journal,
      ),
      isRead: data['isRead'] ?? false,
      typeLabel: data['typeLabel'],
    );
  }

  /// Convert NotificationModel to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString(),
      'isRead': isRead,
      'typeLabel': typeLabel,
    };
  }

  /// Mock notifications for testing UI
  static List<NotificationModel> get mockNotifications {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    return [
      NotificationModel(
        id: '1',
        title: 'Ovulation in 2 days',
        description: 'Your fertile window is starting soon. Take care! 🌸',
        timestamp: DateTime(now.year, now.month, now.day, 9, 0),
        type: NotificationType.ovulation,
      ),
      NotificationModel(
        id: '2',
        title: 'Time to take Iron Supplement',
        description: 'Consistency is the key to better health. 💊',
        timestamp: DateTime(now.year, now.month, now.day, 10, 0),
        type: NotificationType.medication,
      ),
      NotificationModel(
        id: '3',
        title: 'Don’t forget to log your mood',
        description: 'How are you feeling today? Your Mood Garden misses you! 🌼',
        timestamp: DateTime(now.year, now.month, now.day, 12, 0),
        type: NotificationType.moodTracker,
      ),
      NotificationModel(
        id: '4',
        title: 'Derma Visit Tomorrow',
        description: 'You have a dermatology appointment tomorrow at 10:00 AM.',
        timestamp: DateTime(yesterday.year, yesterday.month, yesterday.day, 20, 0),
        type: NotificationType.dermaVisit,
      ),
      NotificationModel(
        id: '5',
        title: 'Period expected in 3 days',
        description: 'Your period is expected on April 06, 2026.',
        timestamp: DateTime(yesterday.year, yesterday.month, yesterday.day, 19, 0),
        type: NotificationType.period,
      ),
      NotificationModel(
        id: '6',
        title: 'Period log reminder',
        description: 'You haven’t logged your period today. Update your cycle.',
        timestamp: DateTime(yesterday.year, yesterday.month, yesterday.day, 18, 0),
        type: NotificationType.periodLog,
      ),
      NotificationModel(
        id: '7',
        title: 'Journal reminder',
        description: 'Write down your thoughts and feelings of today. ✨',
        timestamp: DateTime(yesterday.year, yesterday.month, yesterday.day, 21, 0),
        type: NotificationType.journal,
      ),
    ];
  }
}
