import 'package:cloud_firestore/cloud_firestore.dart';

class MoodLogModel {
  final String id;
  final String moodType;
  final String note;
  final List<String> factors;
  final String dateString;
  final DateTime timestamp;

  MoodLogModel({
    required this.id,
    required this.moodType,
    required this.note,
    required this.factors,
    required this.dateString,
    required this.timestamp,
  });

  factory MoodLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedTime = DateTime.now();
    if (data['timestamp'] is Timestamp) {
      parsedTime = (data['timestamp'] as Timestamp).toDate();
    }

    return MoodLogModel(
      id: doc.id,
      moodType: data['moodType'] ?? 'Calm',
      note: data['note'] ?? '',
      factors: List<String>.from(data['factors'] ?? []),
      dateString: data['dateString'] ?? '',
      timestamp: parsedTime,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'moodType': moodType,
      'note': note,
      'factors': factors,
      'dateString': dateString,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}