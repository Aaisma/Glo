import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/community_models.dart';
import '../model/shared_models.dart';
import 'community_moderation_repo.dart';

class CommunityModerationRepoImpl implements CommunityModerationRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ModerationItem>> getModerationQueue({
    required int page,
    required int limit,
    required bool isArchived,
    ContentType? filterType,
  }) async {
    Query q = _firestore.collection('moderation_queue')
        .where('isArchived', isEqualTo: isArchived)
        .where('isDeleted', isEqualTo: false)
        .where('contentType', whereIn: [ContentType.discussion.name, ContentType.poll.name])
        .orderBy('reportedAt', descending: true);

    final snapshot = await q.get();

    var allItems = snapshot.docs.map((d) {
      final map = d.data() as Map<String, dynamic>;
      map['id'] = d.id;
      return ModerationItem.fromMap(map);
    }).toList();

    if (filterType != null) {
      allItems = allItems.where((item) => item.contentType == filterType).toList();
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= allItems.length) return [];
    final endIndex = (startIndex + limit) > allItems.length ? allItems.length : (startIndex + limit);
    return allItems.sublist(startIndex, endIndex);
  }

  @override
  Future<ModerationItem?> getModerationDetail(String id) async {
    var doc = await _firestore.collection('moderation_queue').doc(id).get();
    if (doc.exists) {
      final map = doc.data()!;
      map['id'] = doc.id;
      return ModerationItem.fromMap(map);
    }

    final snapshot = await _firestore.collection('moderation_queue')
        .where('contentId', isEqualTo: id)
        .where('contentType', whereIn: [ContentType.discussion.name, ContentType.poll.name])
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final map = snapshot.docs.first.data();
      map['id'] = snapshot.docs.first.id;
      return ModerationItem.fromMap(map);
    }
    return null;
  }

  @override
  Future<void> reportContent({
    required String contentId,
    required ContentType contentType,
    required String title,
    required String authorName,
    required String contentSnippet,
    required ModerationReason reason,
  }) async {
    final snapshot = await _firestore.collection('moderation_queue')
        .where('contentId', isEqualTo: contentId)
        .where('contentType', isEqualTo: contentType.name)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      final existing = ModerationItem.fromMap(snapshot.docs.first.data());
      final reasons = List<ModerationReason>.from(existing.reasons);
      if (!reasons.contains(reason)) {
        reasons.add(reason);
      }
      await _firestore.collection('moderation_queue').doc(docId).update({
        'reportsCount': existing.reportsCount + 1,
        'reasons': reasons.map((e) => e.name).toList(),
        'reportedAt': FieldValue.serverTimestamp(),
      });
    } else {
      final id = 'comm_mod_${DateTime.now().millisecondsSinceEpoch}';
      final item = ModerationItem(
        id: id,
        contentId: contentId,
        contentType: contentType,
        title: title,
        authorName: authorName,
        contentSnippet: contentSnippet,
        reasons: [reason],
        reportsCount: 1,
        hiddenCount: 0,
        reportedAt: DateTime.now(),
      );
      await _firestore.collection('moderation_queue').doc(id).set(item.toMap());
    }
  }

  @override
  Future<void> archiveModerationItem(String id) async {
    await _firestore.collection('moderation_queue').doc(id).update({'isArchived': true});
  }

  @override
  Future<void> softDeleteContent(String id) async {
    ModerationItem? item = await getModerationDetail(id);
    if (item == null) return;

    await _firestore.collection('moderation_queue').doc(item.id).update({'isDeleted': true});

    String collectionName = item.contentType == ContentType.discussion ? 'discussions' : 'community_polls';

    await _firestore.collection(collectionName).doc(item.contentId).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }
}
