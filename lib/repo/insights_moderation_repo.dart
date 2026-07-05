import '../model/community_models.dart';

abstract class InsightsModerationRepo {
  Future<List<ModerationItem>> getModerationQueue({
    required int page,
    required int limit,
    required bool isArchived,
  });
  Future<ModerationItem?> getModerationDetail(String id);
  Future<void> reportContent({
    required String contentId,
    required String title,
    required String authorName,
    required String contentSnippet,
    required ModerationReason reason,
  });
  Future<void> recordHiddenContent({
    required String contentId,
    required String title,
    required String authorName,
    required String contentSnippet,
  });
  Future<void> archiveModerationItem(String id);
  Future<void> softDeleteContent(String id);
}
