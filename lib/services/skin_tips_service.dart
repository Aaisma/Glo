import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glo/model/skin_tip_model.dart';
class SkinTipsService {
  final _db = FirebaseFirestore.instance;

  /// Add a new skin tip for a user
  Future<void> addSkinTip(SkinTip tip, String userId) async {
    await _db.collection('skin_tips').doc(tip.id).set({
      ...tip.toMap(),
      'userId': userId,
    });
  }

  /// Fetch all skin tips for a given user (real-time stream)
  Stream<List<SkinTip>> fetchSkinTips(String userId) {
    return _db
        .collection('skin_tips')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => SkinTip.fromMap(doc.data(), doc.id)).toList());
  }

  /// Update an existing skin tip
  Future<void> updateSkinTip(SkinTip tip) async {
    await _db.collection('skin_tips').doc(tip.id).update(tip.toMap());
  }

  /// Delete a skin tip by ID
  Future<void> deleteSkinTip(String id) async {
    await _db.collection('skin_tips').doc(id).delete();
  }
}
