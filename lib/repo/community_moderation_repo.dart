import '../model/community_models.dart';
import '../model/shared_models.dart';

abstract class CommunityModerationRepo {
  Future<List<ModerationItem>> getModerationQueue({
    required int page,
    required int limit,
    required bool isArchived,
    ContentType? filterType,
  });
  Future<ModerationItem?> getModerationDetail(String id);
  Future<void> reportContent({
    required String contentId,
    required ContentType contentType,
    required String title,
    required String authorName,
    required String contentSnippet,
    required ModerationReason reason,
  });
  Future<void> archiveModerationItem(String id);
  Future<void> softDeleteContent(String id);
}
