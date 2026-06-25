import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glo/model/user_model_mood.dart';

class UserModelMood {
  final String id;
  final String moodType;
  final String note;
  final List<String> factors;
  final DateTime date;

  UserModelMood({
    required this.id,
    required this.moodType,
    required this.note,
    required this.factors,
    required this.date,
  });

  factory UserModelMood.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedDate = DateTime.now();
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    }

    return UserModelMood(
      id: doc.id,
      moodType: data['moodType'] ?? 'Calm',
      note: data['note'] ?? '',
      factors: List<String>.from(data['factors'] ?? []),
      date: parsedDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'moodType': moodType,
      'note': note,
      'factors': factors,
      'date': Timestamp.fromDate(date),
    };
  }
}
