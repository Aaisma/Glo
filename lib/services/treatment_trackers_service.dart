import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glo/model/treatment_tracker_model.dart';

class TreatmentTrackersService {
  final _db = FirebaseFirestore.instance;

  /// Add a new treatment tracker for a user
  Future<void> addTracker(TreatmentTracker tracker, String userId) async {
    await _db.collection('treatment_trackers').doc(tracker.id).set({
      ...tracker.toMap(),
      'userId': userId,
    });
  }

  /// Fetch all trackers for a given user (real-time stream)
  Stream<List<TreatmentTracker>> fetchTrackers(String userId) {
    return _db
        .collection('treatment_trackers')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => TreatmentTracker.fromMap(doc.data(), doc.id)).toList());
  }

  /// Update an existing tracker
  Future<void> updateTracker(TreatmentTracker tracker) async {
    await _db.collection('treatment_trackers').doc(tracker.id).update(tracker.toMap());
  }

  /// Delete a tracker by ID
  Future<void> deleteTracker(String id) async {
    await _db.collection('treatment_trackers').doc(id).delete();
  }
}
