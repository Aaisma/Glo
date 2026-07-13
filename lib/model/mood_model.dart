import 'package:cloud_firestore/cloud_firestore.dart';

class MoodLogModel {
  final String id;
  final String userId;
  final String moodType;
  final String note;
  final List<String> factors;
  final DateTime timestamp;

  MoodLogModel({
    required this.id,
    required this.userId,
    required this.moodType,
    required this.note,
    required this.factors,
    required this.timestamp,
  });

  /// Alias so screens that read `.date` (e.g. MoodCalendarScreen) keep working
  DateTime get date => timestamp;

  factory MoodLogModel.fromMap(String id, Map<String, dynamic> map) {
    return MoodLogModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      moodType: map['moodType'] as String? ?? '',
      note: map['note'] as String? ?? '',
      factors: List<String>.from(map['factors'] as List? ?? []),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'moodType': moodType,
      'note': note,
      'factors': factors,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}