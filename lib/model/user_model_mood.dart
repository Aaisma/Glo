import 'package:cloud_firestore/cloud_firestore.dart';

class UserModelMood {
  final String id;
  final String userId;
  final String moodType;
  final String note;
  final List<String> factors;
  final DateTime timestamp;

  UserModelMood({
    required this.id,
    required this.userId,
    required this.moodType,
    required this.note,
    required this.factors,
    required this.timestamp,
  });

  // Alias so `.date` works anywhere `.timestamp` does.
  DateTime get date => timestamp;

  factory UserModelMood.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedTime = DateTime.now();
    final rawTimestamp = data['timestamp'] ?? data['date'];
    if (rawTimestamp is Timestamp) {
      parsedTime = rawTimestamp.toDate();
    }

    return UserModelMood(
      id: doc.id,
      userId: data['userId'] ?? '',
      moodType: data['moodType'] ?? 'Calm',
      note: data['note'] ?? '',
      factors: List<String>.from(data['factors'] ?? []),
      timestamp: parsedTime,
    );
  }
}