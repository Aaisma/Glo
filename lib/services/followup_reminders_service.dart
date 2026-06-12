import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glo/model/followup_reminder_model.dart';

class FollowUpRemindersService {
  final _db = FirebaseFirestore.instance;

  /// Add a new follow-up reminder for a user
  Future<void> addReminder(FollowUpReminder reminder, String userId) async {
    await _db.collection('followup_reminders').doc(reminder.id).set({
      ...reminder.toMap(),
      'userId': userId,
    });
  }

  /// Fetch all reminders for a given user (real-time stream)
  Stream<List<FollowUpReminder>> fetchReminders(String userId) {
    return _db
        .collection('followup_reminders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => FollowUpReminder.fromMap(doc.data(), doc.id)).toList());
  }

  /// Update an existing reminder
  Future<void> updateReminder(FollowUpReminder reminder) async {
    await _db.collection('followup_reminders').doc(reminder.id).update(reminder.toMap());
  }

  /// Delete a reminder by ID
  Future<void> deleteReminder(String id) async {
    await _db.collection('followup_reminders').doc(id).delete();
  }
}
