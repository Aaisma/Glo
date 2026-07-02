import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/insight_models.dart';
import '../model/shared_models.dart';
import 'insights_repo.dart';

class InsightsRepoImpl implements InsightsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? 'unknown_user';

  @override
  Future<List<Insight>> getInsights({
    required int page,
    required int limit,
    String? query,
    String? category,
  }) async {
    Query q = _firestore.collection('insights')
        .where('isDeleted', isEqualTo: false)
        .where('status', isEqualTo: InsightStatus.published.name);

    if (category != null && category.trim().isNotEmpty && category != 'Trending') {
      q = q.where('category', isEqualTo: category);
    } else if (category == 'Trending') {
      q = q.where('isTrending', isEqualTo: true);
    }

    // Since Firestore doesn't support full-text search easily with standard queries,
    // we fetch and filter locally if a query is present (for MVP purposes).
    // In production, we'd use Algolia or ElasticSearch.
    final snapshot = await q.get();
    var allItems = snapshot.docs.map((d) {
      final map = d.data() as Map<String, dynamic>;
      map['id'] = d.id;
      return Insight.fromMap(map);
    }).toList();

    if (query != null && query.trim().isNotEmpty) {
      final queryLower = query.toLowerCase();
      allItems = allItems.where((item) =>
          item.title.toLowerCase().contains(queryLower) ||
          item.summary.toLowerCase().contains(queryLower) ||
          item.content.toLowerCase().contains(queryLower)).toList();
    }
    
    // Sort locally to avoid Firestore composite index requirement
    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final startIndex = (page - 1) * limit;
    if (startIndex >= allItems.length) {
      return [];
    }
    final endIndex = (startIndex + limit) > allItems.length ? allItems.length : (startIndex + limit);
    return allItems.sublist(startIndex, endIndex);
  }

  @override
  Future<Insight?> getFeaturedInsight() async {
    final snapshot = await _firestore.collection('insights')
        .where('isDeleted', isEqualTo: false)
        .where('status', isEqualTo: InsightStatus.published.name)
        .where('isFeatured', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) return null;
    
    var allFeatured = snapshot.docs.map((d) {
      final map = d.data();
      map['id'] = d.id;
      return Insight.fromMap(map);
    }).toList();
    
    allFeatured.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allFeatured.first;
  }

  @override
  Future<Insight?> getInsightById(String id) async {
    final doc = await _firestore.collection('insights').doc(id).get();
    if (!doc.exists) return null;
    final map = doc.data()!;
    map['id'] = doc.id;
    final insight = Insight.fromMap(map);
    return insight.isDeleted ? null : insight;
  }

  @override
  Future<List<Insight>> getRelatedInsights(String insightId) async {
    final original = await getInsightById(insightId);
    if (original == null) return [];

    final snapshot = await _firestore.collection('insights')
        .where('isDeleted', isEqualTo: false)
        .where('status', isEqualTo: InsightStatus.published.name)
        .get();

    final allItems = snapshot.docs
        .where((d) => d.id != insightId)
        .map((d) {
          final map = d.data();
          map['id'] = d.id;
          return Insight.fromMap(map);
        })
        .toList();

    var related = allItems.where((e) => e.category == original.category).toList();
    if (related.length < 3) {
      final others = allItems.where((e) => e.category != original.category).toList();
      related.addAll(others);
    }

    if (related.length > 5) {
      return related.sublist(0, 5);
    }
    return related;
  }

  @override
  Future<void> toggleSaveInsight(String id) async {
    if (_auth.currentUser == null) return;
    
    final favRef = _firestore.collection('users').doc(_uid).collection('favorites').doc(id);
    final insightRef = _firestore.collection('insights').doc(id);

    return _firestore.runTransaction((transaction) async {
      final favDoc = await transaction.get(favRef);
      final insightDoc = await transaction.get(insightRef);
      
      if (!insightDoc.exists) return;
      
      final currentSaves = insightDoc.data()?['saves'] ?? 0;

      if (favDoc.exists) {
        // Remove favorite
        transaction.delete(favRef);
        transaction.update(insightRef, {'saves': (currentSaves - 1).clamp(0, 999999)});
      } else {
        // Add favorite
        final item = FavoriteItem(
          id: id,
          contentId: id,
          type: FavoriteType.article,
          savedAt: DateTime.now(),
        );
        transaction.set(favRef, item.toMap());
        transaction.update(insightRef, {'saves': currentSaves + 1});
      }
    });
  }

  @override
  Future<List<Insight>> getSavedInsights() async {
    if (_auth.currentUser == null) return [];
    final snapshot = await _firestore.collection('users').doc(_uid).collection('favorites')
        .where('type', isEqualTo: FavoriteType.article.name)
        .get();
    
    final result = <Insight>[];
    for (var doc in snapshot.docs) {
      final ins = await getInsightById(doc.id);
      if (ins != null) {
        result.add(ins);
      }
    }
    return result;
  }

  @override
  Future<void> saveDraft(DraftItem draft) async {
    if (_auth.currentUser == null) return;
    await _firestore.collection('users').doc(_uid).collection('drafts').doc(draft.id).set(draft.toMap());
  }

  @override
  Future<DraftItem?> getDraft(String id) async {
    if (_auth.currentUser == null) return null;
    final doc = await _firestore.collection('users').doc(_uid).collection('drafts').doc(id).get();
    if (!doc.exists) return null;
    return DraftItem.fromMap(doc.data()!);
  }

  @override
  Future<void> discardDraft(String id) async {
    if (_auth.currentUser == null) return;
    await _firestore.collection('users').doc(_uid).collection('drafts').doc(id).delete();
  }

  @override
  Future<void> publishInsight(Insight insight) async {
    // Delete draft if exists
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_uid).collection('drafts').doc(insight.id).delete();
    }
    
    final now = DateTime.now();
    final published = insight.copyWith(
      status: InsightStatus.published,
      publishedAt: now,
    );
    await _firestore.collection('insights').doc(published.id).set(published.toMap());
  }

  @override
  Future<void> archiveInsight(String id) async {
    await _firestore.collection('insights').doc(id).update({
      'status': InsightStatus.archived.name,
    });
  }

  @override
  Future<void> duplicateInsight(String id) async {
    if (_auth.currentUser == null) return;
    final original = await getInsightById(id);
    if (original != null) {
      final newId = 'art_${DateTime.now().millisecondsSinceEpoch}';
      final duplicate = original.copyWith(
        id: newId,
        title: '${original.title} (Copy)',
        createdAt: DateTime.now(),
        status: InsightStatus.draft,
        views: 0,
        likes: 0,
        saves: 0,
        shares: 0,
      );
      final item = DraftItem(
        id: newId,
        type: DraftType.insightArticle,
        content: duplicate.toMap(),
        updatedAt: DateTime.now(),
      );
      await saveDraft(item);
    }
  }

  @override
  Future<List<Insight>> getAllAdminInsights() async {
    final snapshot = await _firestore.collection('insights').where('isDeleted', isEqualTo: false).get();
    return snapshot.docs.map((d) {
      final map = d.data();
      map['id'] = d.id;
      return Insight.fromMap(map);
    }).toList();
  }

  @override
  Future<void> addView(String id) async {
    final insightRef = _firestore.collection('insights').doc(id);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(insightRef);
      if (doc.exists) {
        final currentViews = doc.data()?['views'] ?? 0;
        transaction.update(insightRef, {'views': currentViews + 1});
      }
    });
  }

  @override
  Future<void> likeInsight(String id) async {
    if (_auth.currentUser == null) return;
    
    final likeRef = _firestore.collection('users').doc(_uid).collection('likes').doc(id);
    final insightRef = _firestore.collection('insights').doc(id);

    return _firestore.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);
      final insightDoc = await transaction.get(insightRef);
      
      if (!insightDoc.exists) return;
      
      final currentLikes = insightDoc.data()?['likes'] ?? 0;

      if (likeDoc.exists) {
        // Unlike
        transaction.delete(likeRef);
        transaction.update(insightRef, {'likes': (currentLikes - 1).clamp(0, 999999)});
      } else {
        // Like
        transaction.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
        transaction.update(insightRef, {'likes': currentLikes + 1});
      }
    });
  }

  @override
  Future<bool> isInsightLiked(String id) async {
    if (_auth.currentUser == null) return false;
    final doc = await _firestore.collection('users').doc(_uid).collection('likes').doc(id).get();
    return doc.exists;
  }

  @override
  Future<void> hideInsight(String id) async {
    if (_auth.currentUser == null) return;
    final hidden = HiddenContent(
      userId: _uid,
      contentId: id,
      type: ContentType.article,
    );
    await _firestore.collection('users').doc(_uid).collection('hidden_content').doc('hidden_$id').set(hidden.toMap());
  }
}
