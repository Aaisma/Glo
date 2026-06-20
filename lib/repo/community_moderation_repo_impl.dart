import 'package:hive/hive.dart';
import '../model/community_models.dart';
import '../model/shared_models.dart';
import 'community_moderation_repo.dart';

class CommunityModerationRepoImpl implements CommunityModerationRepo {
  final Box _box;

  CommunityModerationRepoImpl({Box? box})
      : _box = box ?? Hive.box('community_moderation_box') {
    _initMockData();
  }

  void _initMockData() {
    if (_box.isEmpty) {
      final now = DateTime.now();
      final mocks = [
        ModerationItem(
          id: 'comm_mod_1',
          contentId: 'disc_1', // links to mock Samantha discussion
          contentType: ContentType.discussion,
          title: "What's one habit that has changed your life for the better?",
          authorName: 'samantha_g',
          contentSnippet: "For me, it is waking up at 6 AM and reading for 30 minutes...",
          reasons: [ModerationReason.harassment],
          reportsCount: 5,
          hiddenCount: 0,
          reportedAt: now.subtract(const Duration(days: 2)),
        ),
        ModerationItem(
          id: 'comm_mod_2',
          contentId: 'poll_1', // links to mock Poll 1
          contentType: ContentType.poll,
          title: "If eligible for a work-from-home position, what do you prefer most?",
          authorName: 'admin_1',
          contentSnippet: "Focus time, balance, flexible schedule...",
          reasons: [ModerationReason.spam],
          reportsCount: 1,
          hiddenCount: 0,
          reportedAt: now.subtract(const Duration(days: 1)),
        ),
      ];

      for (var mock in mocks) {
        _box.put(mock.id, mock.toMap());
      }
    }
  }

  @override
  Future<List<ModerationItem>> getModerationQueue({
    required int page,
    required int limit,
    required bool isArchived,
    ContentType? filterType,
  }) async {
    final allItems = _box.values
        .where((e) {
          if (e is! Map) return false;
          final item = ModerationItem.fromMap(Map<String, dynamic>.from(e));
          if (item.isDeleted) return false;
          return item.isArchived == isArchived;
        })
        .map((e) => ModerationItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    allItems.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));

    var filtered = allItems;
    if (filterType != null) {
      filtered = filtered.where((item) => item.contentType == filterType).toList();
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) return [];
    final endIndex = (startIndex + limit) > filtered.length ? filtered.length : (startIndex + limit);
    return filtered.sublist(startIndex, endIndex);
  }

  @override
  Future<ModerationItem?> getModerationDetail(String id) async {
    final raw = _box.get(id);
    if (raw != null) {
      return ModerationItem.fromMap(Map<String, dynamic>.from(raw));
    }
    for (var val in _box.values) {
      if (val is Map) {
        final item = ModerationItem.fromMap(Map<String, dynamic>.from(val));
        if (item.contentId == id) {
          return item;
        }
      }
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
    ModerationItem? existing = await getModerationDetail(contentId);
    if (existing != null) {
      final reasons = List<ModerationReason>.from(existing.reasons);
      if (!reasons.contains(reason)) {
        reasons.add(reason);
      }
      final updated = existing.copyWith(
        reportsCount: existing.reportsCount + 1,
        reasons: reasons,
        reportedAt: DateTime.now(),
      );
      await _box.put(existing.id, updated.toMap());
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
      await _box.put(id, item.toMap());
    }
  }

  @override
  Future<void> archiveModerationItem(String id) async {
    final raw = _box.get(id);
    if (raw != null) {
      final item = ModerationItem.fromMap(Map<String, dynamic>.from(raw));
      final updated = item.copyWith(isArchived: true);
      await _box.put(id, updated.toMap());
    }
  }

  @override
  Future<void> softDeleteContent(String id) async {
    ModerationItem? item = await getModerationDetail(id);
    if (item == null) return;

    final updatedItem = item.copyWith(isDeleted: true);
    await _box.put(item.id, updatedItem.toMap());

    final now = DateTime.now();
    final box = Hive.box('community_box');
    final raw = box.get(item.contentId);
    if (raw != null) {
      final data = Map<String, dynamic>.from(raw);
      data['isDeleted'] = true;
      data['deletedAt'] = now.toIso8601String();
      await box.put(item.contentId, data);
    }
  }
}
