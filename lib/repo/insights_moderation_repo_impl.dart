import 'package:hive/hive.dart';
import '../model/community_models.dart';
import '../model/shared_models.dart';
import 'insights_moderation_repo.dart';

class InsightsModerationRepoImpl implements InsightsModerationRepo {
  final Box _box;

  InsightsModerationRepoImpl({Box? box})
      : _box = box ?? Hive.box('insights_moderation_box') {
    _initMockData();
  }

  void _initMockData() {
    if (_box.isEmpty) {
      final now = DateTime.now();
      final mocks = [
        ModerationItem(
          id: 'ins_mod_1',
          contentId: 'art_2', // Power of Boundaries mock article
          contentType: ContentType.article,
          title: "The Power of Boundaries",
          authorName: 'admin_1',
          contentSnippet: "Boundaries are essential for healthy living. Setting clear...",
          reasons: [ModerationReason.misinformation],
          reportsCount: 3,
          hiddenCount: 0,
          reportedAt: now.subtract(const Duration(hours: 5)),
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

    final startIndex = (page - 1) * limit;
    if (startIndex >= allItems.length) return [];
    final endIndex = (startIndex + limit) > allItems.length ? allItems.length : (startIndex + limit);
    return allItems.sublist(startIndex, endIndex);
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
      final id = 'ins_mod_${DateTime.now().millisecondsSinceEpoch}';
      final item = ModerationItem(
        id: id,
        contentId: contentId,
        contentType: ContentType.article,
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
    final box = Hive.box('insights_box');
    final raw = box.get(item.contentId);
    if (raw != null) {
      final data = Map<String, dynamic>.from(raw);
      data['isDeleted'] = true;
      data['deletedAt'] = now.toIso8601String();
      await box.put(item.contentId, data);
    }
  }
}
