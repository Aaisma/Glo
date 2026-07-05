import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/community_models.dart';
import '../model/shared_models.dart';
import 'community_repo.dart';

class CommunityRepoImpl implements CommunityRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? 'unknown_user';

  @override
  Future<List<CommunityCategory>> getCategories() async {
    final snapshot = await _firestore.collection('community_categories').where('isActive', isEqualTo: true).get();
    return snapshot.docs.map((d) {
      final map = d.data();
      map['id'] = d.id;
      return CommunityCategory.fromMap(map);
    }).toList();
  }

  @override
  Future<CommunityCategory?> getCategoryById(String id) async {
    final doc = await _firestore.collection('community_categories').doc(id).get();
    if (!doc.exists) return null;
    final map = doc.data()!;
    map['id'] = doc.id;
    return CommunityCategory.fromMap(map);
  }

  @override
  Future<List<Discussion>> getDiscussions({
    required int page,
    required int limit,
    String? query,
    String? filter,
  }) async {
    Query q = _firestore.collection('discussions').where('isDeleted', isEqualTo: false);

    final snapshot = await q.get();
    var allItems = snapshot.docs.map((d) {
      final map = d.data() as Map<String, dynamic>;
      map['id'] = d.id;
      return Discussion.fromMap(map);
    }).toList();

    var filtered = allItems;

    if (filter == 'Unanswered') {
      filtered = filtered.where((item) => item.repliesCount == 0).toList();
    } else if (filter == 'Following') {
      return []; 
    }

    if (filter == 'Trending') {
      filtered.sort((a, b) => (b.views + b.likes + b.repliesCount).compareTo(a.views + a.likes + a.repliesCount));
    } else {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    if (query != null && query.trim().isNotEmpty) {
      final queryLower = query.toLowerCase();
      filtered = filtered.where((e) => e.title.toLowerCase().contains(queryLower) || e.content.toLowerCase().contains(queryLower)).toList();
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) return [];
    final endIndex = (startIndex + limit) > filtered.length ? filtered.length : (startIndex + limit);
    return filtered.sublist(startIndex, endIndex);
  }

  @override
  Future<Discussion?> getDiscussionById(String id) async {
    final doc = await _firestore.collection('discussions').doc(id).get();
    if (!doc.exists) return null;
    final map = doc.data()!;
    map['id'] = doc.id;
    final disc = Discussion.fromMap(map);
    return disc.isDeleted ? null : disc;
  }

  @override
  Future<void> addDiscussion(Discussion discussion) async {
    await _firestore.collection('discussions').doc(discussion.id).set(discussion.toMap());
  }

  @override
  Future<void> likeDiscussion(String id) async {
    if (_auth.currentUser == null) return;
    
    final likeRef = _firestore.collection('users').doc(_uid).collection('likes').doc('disc_$id');
    final discRef = _firestore.collection('discussions').doc(id);

    return _firestore.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);
      final discDoc = await transaction.get(discRef);
      
      if (!discDoc.exists) return;
      
      final currentLikes = discDoc.data()?['likes'] ?? 0;

      if (likeDoc.exists) {
        transaction.delete(likeRef);
        transaction.update(discRef, {'likes': (currentLikes - 1).clamp(0, 999999)});
      } else {
        transaction.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
        transaction.update(discRef, {'likes': currentLikes + 1});
      }
    });
  }

  @override
  Future<void> addReply(String discussionId, DiscussionReply reply) async {
    final discRef = _firestore.collection('discussions').doc(discussionId);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(discRef);
      if (!doc.exists) return;

      final disc = Discussion.fromMap(doc.data()!);
      final replies = List<DiscussionReply>.from(disc.replies)..add(reply);
      final updatedCount = replies.where((r) => !r.isDeleted).length;

      transaction.update(discRef, {
        'replies': replies.map((r) => r.toMap()).toList(),
        'repliesCount': updatedCount,
      });
    });
  }

  @override
  Future<void> likeReply(String discussionId, String replyId) async {
    if (_auth.currentUser == null) return;

    final likeRef = _firestore.collection('users').doc(_uid).collection('likes').doc('reply_$replyId');
    final discRef = _firestore.collection('discussions').doc(discussionId);

    await _firestore.runTransaction((transaction) async {
      final likeDoc = await transaction.get(likeRef);
      final discDoc = await transaction.get(discRef);
      
      if (!discDoc.exists) return;

      final disc = Discussion.fromMap(discDoc.data()!);
      
      int likesDiff = 0;
      if (likeDoc.exists) {
        transaction.delete(likeRef);
        likesDiff = -1;
      } else {
        transaction.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
        likesDiff = 1;
      }

      final updatedReplies = disc.replies.map((r) {
        if (r.id == replyId) {
          return r.copyWith(likes: (r.likes + likesDiff).clamp(0, 999999));
        }
        return r;
      }).toList();

      transaction.update(discRef, {
        'replies': updatedReplies.map((x) => x.toMap()).toList(),
      });
    });
  }

  @override
  Future<List<CommunityPoll>> getPolls({required int page, required int limit}) async {
    final snapshot = await _firestore.collection('community_polls').where('isDeleted', isEqualTo: false).get();
    
    final allItems = snapshot.docs.map((d) {
      final map = d.data();
      map['id'] = d.id;
      return CommunityPoll.fromMap(map);
    }).toList();
    
    // Sort locally to avoid Firestore composite index requirement
    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final startIndex = (page - 1) * limit;
    if (startIndex >= allItems.length) return [];
    final endIndex = (startIndex + limit) > allItems.length ? allItems.length : (startIndex + limit);
    return allItems.sublist(startIndex, endIndex);
  }

  @override
  Future<CommunityPoll?> getPollById(String id) async {
    final doc = await _firestore.collection('community_polls').doc(id).get();
    if (!doc.exists) return null;
    final map = doc.data()!;
    map['id'] = doc.id;
    final poll = CommunityPoll.fromMap(map);
    return poll.isDeleted ? null : poll;
  }

  @override
  Future<void> addPoll(CommunityPoll poll) async {
    await _firestore.collection('community_polls').doc(poll.id).set(poll.toMap());
  }

  @override
  Future<void> votePoll(String pollId, String option) async {
    if (_auth.currentUser == null) return;
    
    final pollRef = _firestore.collection('community_polls').doc(pollId);
    final voteRef = _firestore.collection('users').doc(_uid).collection('votes').doc(pollId);

    await _firestore.runTransaction((transaction) async {
      final voteDoc = await transaction.get(voteRef);
      if (voteDoc.exists) return; // User already voted

      final pollDoc = await transaction.get(pollRef);
      if (!pollDoc.exists) return;

      final poll = CommunityPoll.fromMap(pollDoc.data()!);
      final updatedOptions = Map<String, int>.from(poll.options);
      updatedOptions[option] = (updatedOptions[option] ?? 0) + 1;

      transaction.update(pollRef, {
        'options': updatedOptions,
        'totalVotes': poll.totalVotes + 1,
      });

      transaction.set(voteRef, {'votedOption': option, 'votedAt': FieldValue.serverTimestamp()});
    });
  }

  @override
  Future<void> sharePoll(String pollId) async {
    final pollRef = _firestore.collection('community_polls').doc(pollId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(pollRef);
      if (doc.exists) {
        final currentShares = doc.data()?['shares'] ?? 0;
        transaction.update(pollRef, {'shares': currentShares + 1});
      }
    });
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
  Future<List<dynamic>> getCommunityFeed({
    required int page,
    required int limit,
    String? query,
    String? filter,
  }) async {
    if (filter == 'Following') return []; 

    final discussions = await getDiscussions(page: 1, limit: 100, query: query, filter: filter);
    final polls = await getPolls(page: 1, limit: 100);

    final List<dynamic> feed = [];
    feed.addAll(discussions);
    feed.addAll(polls);

    if (filter == 'Trending') {
      feed.sort((a, b) {
        final int aScore = (a is Discussion)
            ? (a.views + a.likes + a.repliesCount)
            : ((a as CommunityPoll).views + a.totalVotes + a.shares);
        final int bScore = (b is Discussion)
            ? (b.views + b.likes + b.repliesCount)
            : ((b as CommunityPoll).views + b.totalVotes + b.shares);
        return bScore.compareTo(aScore);
      });
    } else {
      feed.sort((a, b) {
        final DateTime aTime = (a is Discussion) ? a.createdAt : (a as CommunityPoll).createdAt;
        final DateTime bTime = (b is Discussion) ? b.createdAt : (b as CommunityPoll).createdAt;
        return bTime.compareTo(aTime);
      });
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= feed.length) return [];
    final endIndex = (startIndex + limit) > feed.length ? feed.length : (startIndex + limit);
    return feed.sublist(startIndex, endIndex);
  }

  @override
  Future<List<Discussion>> getAllAdminDiscussions() async {
    final snapshot = await _firestore.collection('discussions').get();
    return snapshot.docs.map((d) {
      final map = d.data();
      map['id'] = d.id;
      return Discussion.fromMap(map);
    }).toList();
  }

  @override
  Future<List<CommunityPoll>> getAllAdminPolls() async {
    final snapshot = await _firestore.collection('community_polls').get();
    return snapshot.docs.map((d) {
      final map = d.data();
      map['id'] = d.id;
      return CommunityPoll.fromMap(map);
    }).toList();
  }

  @override
  Future<void> softDeleteDiscussion(String id) async {
    await _firestore.collection('discussions').doc(id).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> softDeletePoll(String id) async {
    await _firestore.collection('community_polls').doc(id).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> addDiscussionView(String id) async {
    final ref = _firestore.collection('discussions').doc(id);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (doc.exists) {
        final currentViews = doc.data()?['views'] ?? 0;
        transaction.update(ref, {'views': currentViews + 1});
      }
    });
  }

  @override
  Future<void> addPollView(String id) async {
    final ref = _firestore.collection('community_polls').doc(id);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (doc.exists) {
        final currentViews = doc.data()?['views'] ?? 0;
        transaction.update(ref, {'views': currentViews + 1});
      }
    });
  }

  @override
  Future<bool> isDiscussionLiked(String id) async {
    if (_auth.currentUser == null) return false;
    final doc = await _firestore.collection('users').doc(_uid).collection('likes').doc('disc_$id').get();
    return doc.exists;
  }

  @override
  Future<void> hideDiscussion(String id) async {
    if (_auth.currentUser == null) return;
    final hidden = HiddenContent(
      userId: _uid,
      contentId: id,
      type: ContentType.discussion,
    );
    await _firestore.collection('users').doc(_uid).collection('hidden_content').doc('hidden_$id').set(hidden.toMap());
  }

  @override
  Future<List<String>> getHiddenContentIds() async {
    if (_auth.currentUser == null) return [];
    final snapshot = await _firestore.collection('users').doc(_uid).collection('hidden_content').get();
    return snapshot.docs.map((d) => HiddenContent.fromMap(d.data()).contentId).toList();
  }

  @override
  Future<void> toggleSaveDiscussion(String id) async {
    if (_auth.currentUser == null) return;
    
    final favRef = _firestore.collection('users').doc(_uid).collection('favorites').doc('disc_$id');
    final discRef = _firestore.collection('discussions').doc(id);

    return _firestore.runTransaction((transaction) async {
      final favDoc = await transaction.get(favRef);
      final discDoc = await transaction.get(discRef);
      
      if (!discDoc.exists) return;
      
      final currentSaves = discDoc.data()?['saves'] ?? 0;

      if (favDoc.exists) {
        transaction.delete(favRef);
        transaction.update(discRef, {'saves': (currentSaves - 1).clamp(0, 999999)});
      } else {
        final item = FavoriteItem(
          id: 'disc_$id',
          contentId: id,
          type: FavoriteType.discussion,
          savedAt: DateTime.now(),
        );
        transaction.set(favRef, item.toMap());
        transaction.update(discRef, {'saves': currentSaves + 1});
      }
    });
  }

  @override
  Future<List<Discussion>> getSavedDiscussions() async {
    if (_auth.currentUser == null) return [];
    final snapshot = await _firestore.collection('users').doc(_uid).collection('favorites')
        .where('type', isEqualTo: FavoriteType.discussion.name)
        .get();
    
    final result = <Discussion>[];
    for (var doc in snapshot.docs) {
      final item = FavoriteItem.fromMap(doc.data());
      final disc = await getDiscussionById(item.contentId);
      if (disc != null) result.add(disc);
    }
    return result;
  }

  @override
  Future<void> toggleSavePoll(String id) async {
    if (_auth.currentUser == null) return;
    
    final favRef = _firestore.collection('users').doc(_uid).collection('favorites').doc('poll_$id');
    final pollRef = _firestore.collection('community_polls').doc(id);

    return _firestore.runTransaction((transaction) async {
      final favDoc = await transaction.get(favRef);
      final pollDoc = await transaction.get(pollRef);
      
      if (!pollDoc.exists) return;

      if (favDoc.exists) {
        transaction.delete(favRef);
      } else {
        final item = FavoriteItem(
          id: 'poll_$id',
          contentId: id,
          type: FavoriteType.poll,
          savedAt: DateTime.now(),
        );
        transaction.set(favRef, item.toMap());
      }
    });
  }

  @override
  Future<List<CommunityPoll>> getSavedPolls() async {
    if (_auth.currentUser == null) return [];
    final snapshot = await _firestore.collection('users').doc(_uid).collection('favorites')
        .where('type', isEqualTo: FavoriteType.poll.name)
        .get();
    
    final result = <CommunityPoll>[];
    for (var doc in snapshot.docs) {
      final item = FavoriteItem.fromMap(doc.data());
      final poll = await getPollById(item.contentId);
      if (poll != null) result.add(poll);
    }
    return result;
  }
}
