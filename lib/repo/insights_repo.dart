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
  Future<void> archiveInsight(String id);
  Future<void> duplicateInsight(String id);
  Future<List<Insight>> getAllAdminInsights();
  Future<void> addView(String id);
  Future<void> likeInsight(String id);
}
