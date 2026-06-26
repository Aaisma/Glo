import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/journal_entry_model.dart';

class JournalRepoImpl {
  final _db = FirebaseFirestore.instance;

  Future<bool> saveEntry(JournalEntry entry) async {
    try {
      await _db.collection('journals').doc(entry.id).set(entry.toMap());
      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<List<JournalEntry>> getEntries() {
    return _db.collection('journals').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => JournalEntry.fromMap(doc.data())).toList()
    );
  }
}
