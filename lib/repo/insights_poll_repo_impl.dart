import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/insight_models.dart';
import 'insights_poll_repo.dart';

class InsightsPollRepoImpl implements InsightsPollRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? 'unknown_user';

  @override
  Future<List<InsightPoll>> getAllAdminPolls() async {
    final snapshot = await _firestore
        .collection('insight_polls')
        .where('isDeleted', isEqualTo: false)
        .get();

    return snapshot.docs.map((d) {
      final map = d.data();
      map['id'] = d.id;
      return InsightPoll.fromMap(map);
    }).toList();
  }

  @override
  Future<InsightPoll?> getPollById(String id) async {
    final doc = await _firestore.collection('insight_polls').doc(id).get();
    if (!doc.exists) return null;
    final map = doc.data()!;
    map['id'] = doc.id;
    final poll = InsightPoll.fromMap(map);
    return poll.isDeleted ? null : poll;
  }

  @override
  Future<void> savePollDraft(InsightPoll poll) async {
    if (_auth.currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('insight_poll_drafts')
        .doc(poll.id)
        .set(poll.toMap());
  }

  @override
  Future<InsightPoll?> getPollDraft(String id) async {
    if (_auth.currentUser == null) return null;
    final doc = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('insight_poll_drafts')
        .doc(id)
        .get();
    if (!doc.exists) return null;
    final map = doc.data()!;
    map['id'] = doc.id;
    return InsightPoll.fromMap(map);
  }

  @override
  Future<void> discardPollDraft(String id) async {
    if (_auth.currentUser == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('insight_poll_drafts')
        .doc(id)
        .delete();
  }

  @override
  Future<void> publishPoll(InsightPoll poll) async {
    // Delete draft if one exists, same as article publish flow.
    if (_auth.currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('insight_poll_drafts')
          .doc(poll.id)
          .delete();
    }
    await _firestore.collection('insight_polls').doc(poll.id).set(poll.toMap());
  }

  @override
  Future<void> updatePoll(InsightPoll poll) async {
    await _firestore.collection('insight_polls').doc(poll.id).update(poll.toMap());
  }

  @override
  Future<void> archivePoll(String id) async {
    await _firestore.collection('insight_polls').doc(id).update({
      'status': InsightStatus.archived.name,
    });
  }

  @override
  Future<void> deletePoll(String id) async {
    await _firestore.collection('insight_polls').doc(id).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }
}