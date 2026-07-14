import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/journal_model.dart';
import 'journal_repo.dart';

class JournalRepoImpl implements JournalRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addJournal(JournalModel journal) async {
    try {
      await _firestore
          .collection('users')
          .doc(journal.userId)
          .collection('journals')
          .doc(journal.id)
          .set(journal.toMap());
    } catch (e) {
      throw Exception('Failed to add journal: $e');
    }
  }

  @override
  Stream<List<JournalModel>> getJournals(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('journals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                Map<String, dynamic> data = doc.data();
                // Ensure the document ID is set in the model
                if (data['id'] == null || data['id'] == '') {
                  data['id'] = doc.id;
                }
                return JournalModel.fromMap(data);
              })
              .toList(),
        );
  }

  @override
  Future<void> updateJournal(JournalModel journal) async {
    try {
      await _firestore
          .collection('users')
          .doc(journal.userId)
          .collection('journals')
          .doc(journal.id)
          .update(journal.toMap());
    } catch (e) {
      throw Exception('Failed to update journal: $e');
    }
  }

  @override
  Future<void> deleteJournal(String userId, String journalId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('journals')
          .doc(journalId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete journal: $e');
    }
  }
}
