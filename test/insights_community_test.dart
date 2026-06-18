import 'package:flutter_test/flutter_test.dart';
import 'package:glo/viewmodel/community_view_model.dart';
import 'package:glo/repo/community_repo.dart';
import 'package:glo/model/community_models.dart';

import 'package:glo/model/shared_models.dart';

// Create a simple mock repository for testing
class MockCommunityRepo implements CommunityRepo {
  final List<CommunityCategory> categories = [
    CommunityCategory(id: 'cat_1', name: 'Mental Health', color: '#F0E6FF'),
    CommunityCategory(id: 'cat_2', name: 'Self-Care', color: '#FFE5EC'),
  ];

  final List<Discussion> discussions = [];
  final List<CommunityPoll> publishedPolls = [];

  @override
  Future<void> discardDraft(String id) async {}

  @override
  Future<DraftItem?> getDraft(String id) async => null;

  @override
  Future<void> saveDraft(DraftItem draft) async {}

  @override
  Future<List<CommunityCategory>> getCategories() async => categories;

  @override
  Future<CommunityCategory?> getCategoryById(String id) async {
    for (var cat in categories) {
      if (cat.id == id) return cat;
    }
    return null;
  }

  @override
  Future<void> addPoll(CommunityPoll poll) async {
    publishedPolls.add(poll);
  }

  @override
  Future<List<Discussion>> getDiscussions({required int page, required int limit, String? query, String? filter}) async {
    var list = List<Discussion>.from(discussions);
    if (filter == 'Unanswered') {
      list = list.where((d) => d.repliesCount == 0).toList();
    } else if (filter == 'Following') {
      return [];
    }
    
    // Sort
    if (filter == 'Trending') {
      list.sort((a, b) => (b.views + b.likes + b.repliesCount).compareTo(a.views + a.likes + a.repliesCount));
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= list.length) return [];
    final endIndex = (startIndex + limit) > list.length ? list.length : (startIndex + limit);
    return list.sublist(startIndex, endIndex);
  }

  @override
  Future<Discussion?> getDiscussionById(String id) async => null;
  @override
  Future<void> addDiscussion(Discussion discussion) async {
    discussions.add(discussion);
  }
  @override
  Future<void> likeDiscussion(String id) async {}
  @override
  Future<void> addReply(String discussionId, DiscussionReply reply) async {}
  @override
  Future<void> likeReply(String discussionId, String replyId) async {}
  @override
  Future<List<CommunityPoll>> getPolls({required int page, required int limit}) async => publishedPolls;
  @override
  Future<CommunityPoll?> getPollById(String id) async => null;
  @override
  Future<void> votePoll(String pollId, String option) async {}
  @override
  Future<void> sharePoll(String pollId) async {}
  
  @override
  Future<List<dynamic>> getCommunityFeed({required int page, required int limit, String? query, String? filter}) async {
    if (filter == 'Following') return [];
    final discs = await getDiscussions(page: 1, limit: 100, query: query, filter: filter);
    final feed = <dynamic>[...discs, ...publishedPolls];
    
    final startIndex = (page - 1) * limit;
    if (startIndex >= feed.length) return [];
    final endIndex = (startIndex + limit) > feed.length ? feed.length : (startIndex + limit);
    return feed.sublist(startIndex, endIndex);
  }

  @override
  Future<List<Discussion>> getAllAdminDiscussions() async => [];
  @override
  Future<List<CommunityPoll>> getAllAdminPolls() async => [];
  @override
  Future<void> softDeleteDiscussion(String id) async {}
  @override
  Future<void> softDeletePoll(String id) async {}
  @override
  Future<void> addDiscussionView(String id) async {}
  @override
  Future<void> addPollView(String id) async {}
}

void main() {
  group('CreatePollViewModel Option Limit Tests', () {
    late MockCommunityRepo mockRepo;
    late CreatePollViewModel viewModel;

    setUp(() {
      mockRepo = MockCommunityRepo();
      viewModel = CreatePollViewModel(mockRepo);
    });

    test('Initial state should start with 2 option fields', () {
      expect(viewModel.optionControllers.length, equals(2));
      expect(viewModel.canRemoveOption, isFalse); // cannot remove below min (2)
      expect(viewModel.canAddOption, isTrue); // can add up to max (6)
    });

    test('Adding options up to the limit (6) works and blocks further addition', () {
      viewModel.addOptionField(); // 3
      viewModel.addOptionField(); // 4
      viewModel.addOptionField(); // 5
      viewModel.addOptionField(); // 6

      expect(viewModel.optionControllers.length, equals(6));
      expect(viewModel.canAddOption, isFalse); // limit hit
      expect(viewModel.canRemoveOption, isTrue); // can remove down to 2

      // Tapping addOptionField again should do nothing
      viewModel.addOptionField();
      expect(viewModel.optionControllers.length, equals(6));
    });

    test('Removing options down to the limit (2) works and blocks further removal', () {
      viewModel.addOptionField(); // 3
      expect(viewModel.optionControllers.length, equals(3));
      expect(viewModel.canRemoveOption, isTrue);

      viewModel.removeOptionField(2); // remove index 2 (field 3)
      expect(viewModel.optionControllers.length, equals(2));
      expect(viewModel.canRemoveOption, isFalse); // hit bottom limit
    });
  });

  group('CreateDiscussionViewModel Category Tests', () {
    late MockCommunityRepo mockRepo;
    late CreateDiscussionViewModel viewModel;

    setUp(() {
      mockRepo = MockCommunityRepo();
      viewModel = CreateDiscussionViewModel(mockRepo);
    });

    test('loadCategories populates categories list and defaults categoryId', () async {
      expect(viewModel.categories, isEmpty);
      expect(viewModel.categoryId, isNull);

      await viewModel.loadCategories();

      expect(viewModel.categories.length, equals(2));
      expect(viewModel.categories[0].name, equals('Mental Health'));
      expect(viewModel.categoryId, equals('cat_1')); // default is first item
    });

    test('setCategory updates categoryId value', () async {
      await viewModel.loadCategories();
      expect(viewModel.categoryId, equals('cat_1'));

      viewModel.setCategory('cat_2');
      expect(viewModel.categoryId, equals('cat_2'));
    });
  });

  group('CommunityFeedViewModel Filter Tests', () {
    late MockCommunityRepo mockRepo;
    late CommunityFeedViewModel viewModel;

    setUp(() {
      mockRepo = MockCommunityRepo();
      viewModel = CommunityFeedViewModel(mockRepo);

      // Populate discussions
      mockRepo.discussions.addAll([
        Discussion(
          id: 'disc_1',
          title: 'Unanswered discussion',
          content: 'No replies',
          username: 'User1',
          isAnonymous: false,
          categoryId: 'cat_1',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          replies: [],
          repliesCount: 0,
        ),
        Discussion(
          id: 'disc_2',
          title: 'Answered discussion',
          content: 'Has replies',
          username: 'User2',
          isAnonymous: false,
          categoryId: 'cat_2',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          replies: [],
          repliesCount: 3,
        ),
      ]);
    });

    test('loadFeed loads categories and feed items', () async {
      expect(viewModel.categories, isEmpty);
      expect(viewModel.feedItems, isEmpty);

      await viewModel.loadFeed();

      expect(viewModel.categories.length, equals(2));
      expect(viewModel.feedItems.length, equals(2));
    });

    test('Following filter returns empty feed (Phase 1)', () async {
      await viewModel.loadFeed();
      expect(viewModel.feedItems.length, equals(2));

      await viewModel.setFilter('Following');

      expect(viewModel.selectedFilter, equals('Following'));
      expect(viewModel.feedItems, isEmpty);
    });

    test('Unanswered filter filters out discussion with replies', () async {
      await viewModel.loadFeed();
      expect(viewModel.feedItems.length, equals(2));

      await viewModel.setFilter('Unanswered');

      expect(viewModel.selectedFilter, equals('Unanswered'));
      // Only disc_1 has 0 replies
      expect(viewModel.feedItems.length, equals(1));
      expect((viewModel.feedItems.first as Discussion).id, equals('disc_1'));
    });
  });
}
