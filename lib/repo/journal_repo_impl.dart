import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/journal_entry_model.dart';

class JournalRepoImpl {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Save a journal entry to Firestore
  Future<bool> saveEntry(JournalEntry entry) async {
    try {
      await _db.collection('journals').doc(entry.id).set(entry.toMap());
      return true;
    } catch (e) {
      print("Error saving entry: $e");
      return false;
    }
  }

  /// Fetch all journal entries as a stream
  Stream<List<JournalEntry>> getEntries() {
    return _db.collection('journals').orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => JournalEntry.fromMap(doc.data())).toList(),
    );
  }

  /// Update an existing journal entry
  Future<bool> updateEntry(JournalEntry entry) async {
    try {
      await _db.collection('journals').doc(entry.id).update(entry.toMap());
      return true;
    } catch (e) {
      print("Error updating entry: $e");
      return false;
    }
  }

  /// Delete a journal entry
  Future<bool> deleteEntry(String id) async {
    try {
      await _db.collection('journals').doc(id).delete();
      return true;
    } catch (e) {
      print("Error deleting entry: $e");
      return false;
    }
  }
}
