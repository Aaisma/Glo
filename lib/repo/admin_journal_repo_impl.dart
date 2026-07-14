import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/journal_model.dart';
import 'admin_journal_repo.dart';

class AdminJournalRepoImpl implements AdminJournalRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = "journals";

  @override
  Stream<List<JournalModel>> getAllJournals() {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => JournalModel.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> deleteJournal(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  @override
  Future<void> updateJournalStatus(String id, Map<String, dynamic> updates) async {
    await _firestore.collection(collection).doc(id).update(updates);
  }
}
