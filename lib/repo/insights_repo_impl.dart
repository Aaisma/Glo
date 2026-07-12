import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';
import '../model/journal_model.dart';
import 'journal_repo.dart';

class JournalRepoImpl implements JournalRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addJournal(JournalModel journal) async {
    await _firestore
        .collection('users')
        .doc(journal.userId)
        .collection('journals')
        .doc(journal.id)
        .set(journal.toMap());
  }

  @override
  Stream<List<JournalModel>> getJournals(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('journals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((e) => JournalModel.fromMap(e.data()))
        .toList());
  }

  @override
  Future<void> updateJournal(JournalModel journal) async {
    await _firestore
        .collection('users')
        .doc(journal.userId)
        .collection('journals')
        .doc(journal.id)
        .update(journal.toMap());
  }

  @override
  Future<void> deleteJournal(String userId, String journalId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('journals')
        .doc(journalId)
        .delete();
  }
}