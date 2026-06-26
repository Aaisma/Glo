import 'dart:async';
import 'package:flutter/material.dart';
import '../model/community_models.dart';
import '../model/shared_models.dart';
import '../repo/community_repo.dart';
import '../repo/community_moderation_repo.dart';

class CommunityFeedViewModel extends ChangeNotifier {
  final CommunityRepo _repo;

  CommunityFeedViewModel(this._repo);

  List<dynamic> _feedItems = []; // Contains Discussion and CommunityPoll
  List<dynamic> get feedItems => _feedItems;

  List<CommunityCategory> _categories = [];
  List<CommunityCategory> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _error;
  String? get error => _error;

  int _page = 1;
  final int _limit = 5;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedFilter = 'Trending'; // 'Trending', 'Recent', 'Unanswered', 'Following'
  String get selectedFilter => _selectedFilter;

  Future<void> setFilter(String filter) async {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    notifyListeners();
    await loadFeed(isRefresh: true);
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    notifyListeners();
    await loadFeed(isRefresh: true);
  }

  Future<void> loadFeed({bool isRefresh = false}) async {
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
    }

    if (_page == 1) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      // Load categories
      _categories = await _repo.getCategories();

      // Read hidden content IDs from box
      final hiddenIds = await _repo.getHiddenContentIds();

      // Load feed items
      final items = await _repo.getCommunityFeed(
        page: _page,
        limit: _limit,
        query: _searchQuery.isEmpty ? null : _searchQuery,
        filter: _selectedFilter,
      );

      final filteredItems = items.where((item) {
        if (item is Discussion && hiddenIds.contains(item.id)) return false;
        if (item is CommunityPoll && hiddenIds.contains(item.id)) return false;
        return true;
      }).toList();

      if (isRefresh || _page == 1) {
        _feedItems = filteredItems;
      } else {
        _feedItems.addAll(filteredItems);
      }

      if (items.length < _limit) {
        _hasMore = false;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    _page++;
    await loadFeed();
  }
}

class DiscussionDetailViewModel extends ChangeNotifier {
  final CommunityRepo _repo;
  final CommunityModerationRepo _moderationRepo;

  DiscussionDetailViewModel(this._repo, this._moderationRepo);

  Discussion? _discussion;
  Discussion? get discussion => _discussion;

  CommunityCategory? _category;
  CommunityCategory? get category => _category;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLiked = false;
  bool get isLiked => _isLiked;

  final Set<String> _likedReplies = {};
  bool isReplyLiked(String replyId) => _likedReplies.contains(replyId);

  Future<void> loadDiscussion(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repo.addDiscussionView(id);
      _discussion = await _repo.getDiscussionById(id);
      if (_discussion != null) {
        _category = await _repo.getCategoryById(_discussion!.categoryId);

        _isLiked = await _repo.isDiscussionLiked(id);

        // Not fully implementing reply likes fetch locally for MVP since it requires 
        // a similar method. Assume no replies liked initially.
        _likedReplies.clear();
      }
    } catch (e) {
      // error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> like() async {
    if (_discussion == null) return;
    await _repo.likeDiscussion(_discussion!.id);
    _isLiked = !_isLiked;
    _discussion = await _repo.getDiscussionById(_discussion!.id);
    notifyListeners();
  }

  Future<void> addComment(String content) async {
    if (_discussion == null || content.trim().isEmpty) return;

    final reply = DiscussionReply(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      discussionId: _discussion!.id,
      username: 'user_active',
      content: content,
      createdAt: DateTime.now(),
    );

    await _repo.addReply(_discussion!.id, reply);
    await loadDiscussion(_discussion!.id);
  }

  Future<void> likeReply(String replyId) async {
    if (_discussion == null) return;
    await _repo.likeReply(_discussion!.id, replyId);
    if (_likedReplies.contains(replyId)) {
      _likedReplies.remove(replyId);
    } else {
      _likedReplies.add(replyId);
    }
    _discussion = await _repo.getDiscussionById(_discussion!.id);
    notifyListeners();
  }

  Future<void> hide(BuildContext context) async {
    if (_discussion == null) return;
    await _repo.hideDiscussion(_discussion!.id);
    Navigator.of(context).pop();
  }

  Future<void> report(ModerationReason reason) async {
    if (_discussion == null) return;
    await _moderationRepo.reportContent(
      contentId: _discussion!.id,
      contentType: ContentType.discussion,
      title: _discussion!.title,
      authorName: _discussion!.username,
      contentSnippet: _discussion!.content,
      reason: reason,
    );
  }
}

class CreateDiscussionViewModel extends ChangeNotifier {
  final CommunityRepo _repo;
  Timer? _autoSaveTimer;
  String? _activeDraftId;
  String? get activeDraftId => _activeDraftId;
  bool _hasUnsavedChanges = false;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool _showDraftRecovery = false;
  bool get showDraftRecovery => _showDraftRecovery;

  CreateDiscussionViewModel(this._repo) {
    titleController.addListener(_onFieldChanged);
    contentController.addListener(_onFieldChanged);
  }

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  
  String? _categoryId;
  String? get categoryId => _categoryId;

  bool _isAnonymous = false;
  bool get isAnonymous => _isAnonymous;

  List<CommunityCategory> _categories = [];
  List<CommunityCategory> get categories => _categories;

  void _onFieldChanged() {
    _hasUnsavedChanges = true;
    _startTimer();
  }

  void _startTimer() {
    if (_autoSaveTimer != null) return;
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_hasUnsavedChanges) {
        autoSaveDraft();
      }
    });
  }

  Future<void> checkForUnfinishedDraft() async {
    // Draft recovery logic needs getDrafts() implementation.
  }

  Future<void> restoreDraft() async {
    if (_activeDraftId == null) return;
    final draftItem = await _repo.getDraft(_activeDraftId!);
    if (draftItem != null && draftItem.type == DraftType.discussion) {
      titleController.text = draftItem.content['title'] ?? '';
      contentController.text = draftItem.content['content'] ?? '';
      _categoryId = draftItem.content['categoryId'];
      _isAnonymous = draftItem.content['isAnonymous'] ?? false;
      _showDraftRecovery = false;
      _hasUnsavedChanges = false;
      notifyListeners();
    }
  }

  Future<void> discardDraft() async {
    if (_activeDraftId != null) {
      await _repo.discardDraft(_activeDraftId!);
    }
    clearForm();
  }

  Future<void> autoSaveDraft() async {
    if (titleController.text.trim().isEmpty) return;

    final id = _activeDraftId ?? 'disc_draft_${DateTime.now().millisecondsSinceEpoch}';
    _activeDraftId = id;

    final draftMap = {
      'title': titleController.text,
      'content': contentController.text,
      'categoryId': _categoryId,
      'isAnonymous': _isAnonymous,
    };

    final item = DraftItem(
      id: id,
      type: DraftType.discussion,
      content: draftMap,
      updatedAt: DateTime.now(),
    );

    await _repo.saveDraft(item);
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _repo.getCategories();
    if (_categories.isEmpty) {
      _categories = [
        CommunityCategory(id: 'c1', name: 'Health & Wellness', isActive: true, color: '#F0E6FF'),
        CommunityCategory(id: 'c2', name: 'Lifestyle', isActive: true, color: '#FFE5EC'),
        CommunityCategory(id: 'c3', name: 'Community', isActive: true, color: '#F0E6FF'),
        CommunityCategory(id: 'c4', name: 'Expert Insights', isActive: true, color: '#FFE5EC'),
        CommunityCategory(id: 'c5', name: 'Trending', isActive: true, color: '#F0E6FF'),
      ];
    }
    if (_categories.isNotEmpty && _categoryId == null) {
      _categoryId = _categories.first.id;
    }
    notifyListeners();
  }

  void setCategory(String id) {
    _categoryId = id;
    _onFieldChanged();
    notifyListeners();
  }

  void toggleAnonymous(bool val) {
    _isAnonymous = val;
    _onFieldChanged();
    notifyListeners();
  }

  Future<void> publish() async {
    if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty || _categoryId == null) return;

    final disc = Discussion(
      id: 'disc_${DateTime.now().millisecondsSinceEpoch}',
      title: titleController.text,
      content: contentController.text,
      username: _isAnonymous ? 'anonymous' : 'Priya',
      isAnonymous: _isAnonymous,
      categoryId: _categoryId!,
      createdAt: DateTime.now(),
      replies: [],
    );

    await _repo.addDiscussion(disc);
    if (_activeDraftId != null) {
      await _repo.discardDraft(_activeDraftId!);
    }
    clearForm();
  }

  void clearForm() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    titleController.clear();
    contentController.clear();
    _isAnonymous = false;
    _categoryId = null;
    _activeDraftId = null;
    _showDraftRecovery = false;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}

class CreatePollViewModel extends ChangeNotifier {
  final CommunityRepo _repo;
  Timer? _autoSaveTimer;
  String? _activeDraftId;
  String? get activeDraftId => _activeDraftId;
  bool _hasUnsavedChanges = false;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool _showDraftRecovery = false;
  bool get showDraftRecovery => _showDraftRecovery;

  CreatePollViewModel(this._repo) {
    _optionControllers = [
      TextEditingController(),
      TextEditingController(),
    ];
    questionController.addListener(_onFieldChanged);
    for (var controller in _optionControllers) {
      controller.addListener(_onFieldChanged);
    }
  }

  final questionController = TextEditingController();
  List<TextEditingController> _optionControllers = [];
  List<TextEditingController> get optionControllers => _optionControllers;

  String? _categoryId;
  String? get categoryId => _categoryId;

  bool _isAnonymous = false;
  bool get isAnonymous => _isAnonymous;

  List<CommunityCategory> _categories = [];
  List<CommunityCategory> get categories => _categories;

  static const int minOptions = 2;
  static const int maxOptions = 6;

  void _onFieldChanged() {
    _hasUnsavedChanges = true;
    _startTimer();
  }

  void _startTimer() {
    if (_autoSaveTimer != null) return;
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_hasUnsavedChanges) {
        autoSaveDraft();
      }
    });
  }

  Future<void> checkForUnfinishedDraft() async {
    // Draft recovery logic needs getDrafts() implementation.
  }

  Future<void> restoreDraft() async {
    if (_activeDraftId == null) return;
    final draftItem = await _repo.getDraft(_activeDraftId!);
    if (draftItem != null && draftItem.type == DraftType.communityPoll) {
      questionController.text = draftItem.content['question'] ?? '';
      _categoryId = draftItem.content['categoryId'];
      _isAnonymous = draftItem.content['isAnonymous'] ?? false;
      
      final List<String> opts = List<String>.from(draftItem.content['options'] ?? []);
      for (var controller in _optionControllers) {
        controller.dispose();
      }
      _optionControllers.clear();
      for (var opt in opts) {
        final controller = TextEditingController(text: opt);
        controller.addListener(_onFieldChanged);
        _optionControllers.add(controller);
      }
      if (_optionControllers.length < minOptions) {
        final diff = minOptions - _optionControllers.length;
        for (var i = 0; i < diff; i++) {
          final controller = TextEditingController();
          controller.addListener(_onFieldChanged);
          _optionControllers.add(controller);
        }
      }
      
      _showDraftRecovery = false;
      _hasUnsavedChanges = false;
      notifyListeners();
    }
  }

  Future<void> discardDraft() async {
    if (_activeDraftId != null) {
      await _repo.discardDraft(_activeDraftId!);
    }
    clearForm();
  }

  Future<void> autoSaveDraft() async {
    if (questionController.text.trim().isEmpty) return;

    final id = _activeDraftId ?? 'poll_draft_${DateTime.now().millisecondsSinceEpoch}';
    _activeDraftId = id;

    final List<String> optionTexts = _optionControllers.map((c) => c.text).toList();

    final draftMap = {
      'question': questionController.text,
      'options': optionTexts,
      'categoryId': _categoryId,
      'isAnonymous': _isAnonymous,
    };

    final item = DraftItem(
      id: id,
      type: DraftType.communityPoll,
      content: draftMap,
      updatedAt: DateTime.now(),
    );

    await _repo.saveDraft(item);
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _repo.getCategories();
    if (_categories.isEmpty) {
      _categories = [
        CommunityCategory(id: 'c1', name: 'Health & Wellness', isActive: true, color: '#F0E6FF'),
        CommunityCategory(id: 'c2', name: 'Lifestyle', isActive: true, color: '#FFE5EC'),
        CommunityCategory(id: 'c3', name: 'Community', isActive: true, color: '#F0E6FF'),
        CommunityCategory(id: 'c4', name: 'Expert Insights', isActive: true, color: '#FFE5EC'),
        CommunityCategory(id: 'c5', name: 'Trending', isActive: true, color: '#F0E6FF'),
      ];
    }
    if (_categories.isNotEmpty && _categoryId == null) {
      _categoryId = _categories.first.id;
    }
    notifyListeners();
  }

  void setCategory(String id) {
    _categoryId = id;
    _onFieldChanged();
    notifyListeners();
  }

  void toggleAnonymous(bool val) {
    _isAnonymous = val;
    _onFieldChanged();
    notifyListeners();
  }

  void addOptionField() {
    if (_optionControllers.length >= maxOptions) return;
    final controller = TextEditingController();
    controller.addListener(_onFieldChanged);
    _optionControllers.add(controller);
    _onFieldChanged();
    notifyListeners();
  }

  void removeOptionField(int index) {
    if (_optionControllers.length <= minOptions) return;
    _optionControllers[index].dispose();
    _optionControllers.removeAt(index);
    _onFieldChanged();
    notifyListeners();
  }

  bool get canAddOption => _optionControllers.length < maxOptions;
  bool get canRemoveOption => _optionControllers.length > minOptions;

  Future<void> publish() async {
    if (questionController.text.trim().isEmpty || _categoryId == null) return;
    
    final Map<String, int> optionsMap = {};
    for (var controller in _optionControllers) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        optionsMap[text] = 0;
      }
    }

    if (optionsMap.length < minOptions) return;

    final poll = CommunityPoll(
      id: 'poll_${DateTime.now().millisecondsSinceEpoch}',
      question: questionController.text,
      options: optionsMap,
      categoryId: _categoryId!,
      createdAt: DateTime.now(),
      createdBy: _isAnonymous ? 'anonymous' : 'Anu',
      userVotedOption: null,
    );

    await _repo.addPoll(poll);
    if (_activeDraftId != null) {
      await _repo.discardDraft(_activeDraftId!);
    }
    clearForm();
  }

  void clearForm() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    questionController.clear();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _optionControllers = [
      TextEditingController(),
      TextEditingController(),
    ];
    _optionControllers[0].addListener(_onFieldChanged);
    _optionControllers[1].addListener(_onFieldChanged);
    _isAnonymous = false;
    _categoryId = null;
    _activeDraftId = null;
    _showDraftRecovery = false;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class CommunityLibraryViewModel extends ChangeNotifier {
  final CommunityRepo _repo;

  CommunityLibraryViewModel(this._repo);

  List<Discussion> _discussions = [];
  List<Discussion> get discussions => _discussions;

  List<CommunityPoll> _polls = [];
  List<CommunityPoll> get polls => _polls;

  String _selectedTab = 'Discussions'; // 'Discussions', 'Polls'
  String get selectedTab => _selectedTab;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
    loadLibrary();
  }

  Future<void> loadLibrary() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_selectedTab == 'Discussions') {
        _discussions = await _repo.getAllAdminDiscussions();
        _discussions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _polls = await _repo.getAllAdminPolls();
        _polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      // error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDiscussion(String id) async {
    await _repo.softDeleteDiscussion(id);
    await loadLibrary();
  }

  Future<void> deletePoll(String id) async {
    await _repo.softDeletePoll(id);
    await loadLibrary();
  }
}
