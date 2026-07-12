import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/journal_model.dart';
import 'journal_repo.dart';

class JournalRepoImpl implements JournalRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "journals";

  @override
  Future<void> addJournal(JournalModel journal) async {
    await _firestore.collection(collection).doc(journal.id).set(journal.toMap());
  }

  @override
  Stream<List<JournalModel>> getJournals() {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => JournalModel.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> updateJournal(JournalModel journal) async {
    await _firestore.collection(collection).doc(journal.id).update(journal.toMap());
  }

  @override
  Future<void> deleteJournal(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }
}
