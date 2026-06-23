import '../model/community_models.dart';
import '../model/shared_models.dart';

abstract class CommunityRepo {
  Future<List<CommunityCategory>> getCategories();
  Future<CommunityCategory?> getCategoryById(String id);
  
  Future<List<Discussion>> getDiscussions({required int page, required int limit, String? query, String? filter});
  Future<Discussion?> getDiscussionById(String id);
  Future<void> addDiscussion(Discussion discussion);
  Future<void> likeDiscussion(String id);
  Future<void> addReply(String discussionId, DiscussionReply reply);
  Future<void> likeReply(String discussionId, String replyId);
  
  Future<List<CommunityPoll>> getPolls({required int page, required int limit});
  Future<CommunityPoll?> getPollById(String id);
  Future<void> addPoll(CommunityPoll poll);
  Future<void> votePoll(String pollId, String option);
  Future<void> sharePoll(String pollId);

  Future<void> saveDraft(DraftItem draft);
  Future<DraftItem?> getDraft(String id);
  Future<void> discardDraft(String id);

  Future<List<dynamic>> getCommunityFeed({required int page, required int limit, String? query, String? filter});
  Future<List<Discussion>> getAllAdminDiscussions();
  Future<List<CommunityPoll>> getAllAdminPolls();
  Future<void> softDeleteDiscussion(String id);
  Future<void> softDeletePoll(String id);
  Future<void> addDiscussionView(String id);
  Future<void> addPollView(String id);
  Future<bool> isDiscussionLiked(String id);
  Future<void> hideDiscussion(String id);
  Future<List<String>> getHiddenContentIds();
  Future<void> toggleSaveDiscussion(String id);
  Future<List<Discussion>> getSavedDiscussions();
  Future<void> toggleSavePoll(String id);
  Future<List<CommunityPoll>> getSavedPolls();
}
