import '../model/insight_models.dart';
import '../model/shared_models.dart';

abstract class InsightsRepo {
  Future<List<Insight>> getInsights({required int page, required int limit, String? query, String? category});
  Future<Insight?> getFeaturedInsight();
  Future<Insight?> getInsightById(String id);
  Future<List<Insight>> getRelatedInsights(String insightId);
  Future<void> toggleSaveInsight(String id);
  Future<List<Insight>> getSavedInsights();
  Future<void> saveDraft(DraftItem draft);
  Future<DraftItem?> getDraft(String id);
  Future<void> discardDraft(String id);
  Future<void> publishInsight(Insight insight);
  Future<void> updateInsight(Insight insight);
  Future<void> archiveInsight(String id);
  Future<void> deleteInsight(String id);
  Future<void> duplicateInsight(String id);
  Future<List<Insight>> getAllAdminInsights();
  Future<void> addView(String id);
  Future<void> likeInsight(String id);
  Future<bool> isInsightLiked(String id);
  Future<void> hideInsight(String id);
  Future<List<String>> getHiddenContentIds();
  Future<void> addInsightComment(String insightId, InsightComment comment);
  Future<List<InsightComment>> getInsightComments(String insightId);
  Future<void> likeInsightComment(String commentId);
  Future<bool> isInsightCommentLiked(String commentId);
}
