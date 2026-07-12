import 'dart:async';
import 'package:flutter/material.dart';
import '../model/insight_models.dart';
import '../model/community_models.dart';
import '../model/shared_models.dart';
import '../repo/insights_repo.dart';
import '../repo/community_repo.dart';
import '../repo/insights_moderation_repo.dart';

class InsightsFeedViewModel extends ChangeNotifier {
  final InsightsRepo _repo;

  InsightsFeedViewModel(this._repo);

  Insight? _featuredInsight;
  Insight? get featuredInsight => _featuredInsight;

  List<Insight> _latestInsights = [];
  List<Insight> get latestInsights => _latestInsights;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = 'Health & Wellness';
  String get selectedCategory => _selectedCategory;

  int _page = 1;
  final int _limit = 5;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> setCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _latestInsights.clear();
    _featuredInsight = null;
    notifyListeners();
    await loadFeed(isRefresh: true);
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    _latestInsights.clear();
    _featuredInsight = null;
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
      if (_page == 1) {
        _featuredInsight = await _repo.getFeaturedInsight();
      }

      final items = await _repo.getInsights(
        page: _page,
        limit: _limit,
        query: _searchQuery,
        category: _selectedCategory,
      );

      final hiddenIds = await _repo.getHiddenContentIds();
      final filteredItems = items.where((item) => !hiddenIds.contains(item.id)).toList();

      if (isRefresh || _page == 1) {
        _latestInsights = filteredItems;
      } else {
        _latestInsights.addAll(filteredItems);
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

class FavoritesViewModel extends ChangeNotifier {
  final InsightsRepo _insightsRepo;
  final CommunityRepo _communityRepo;

  FavoritesViewModel(this._insightsRepo, this._communityRepo);

  List<Insight> _savedArticles = [];
  List<Insight> get savedArticles => _savedArticles;

  List<CommunityPoll> _savedPolls = [];
  List<CommunityPoll> get savedPolls => _savedPolls;

  List<Discussion> _savedDiscussions = [];
  List<Discussion> get savedDiscussions => _savedDiscussions;

  String _currentTab = 'All'; // 'All', 'Articles', 'Discussions', 'Polls'
  String get currentTab => _currentTab;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setTab(String tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _savedArticles = await _insightsRepo.getSavedInsights();
      _savedDiscussions = await _communityRepo.getSavedDiscussions();
      _savedPolls = await _communityRepo.getSavedPolls();
    } catch (e) {
      // Silent error or handling
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String contentId, FavoriteType type) async {
    if (type == FavoriteType.article) {
      await _insightsRepo.toggleSaveInsight(contentId);
    } else if (type == FavoriteType.discussion) {
      await _communityRepo.toggleSaveDiscussion(contentId);
    } else if (type == FavoriteType.poll) {
      await _communityRepo.toggleSavePoll(contentId);
    }
    await loadFavorites();
  }

  Future<void> removeFavorite(String id, ContentType type) async {
    FavoriteType favType = FavoriteType.article;
    if (type == ContentType.discussion) favType = FavoriteType.discussion;
    if (type == ContentType.poll) favType = FavoriteType.poll;
    await toggleFavorite(id, favType);
  }
}

class ArticleDetailViewModel extends ChangeNotifier {
  final InsightsRepo _repo;
  final InsightsModerationRepo _moderationRepo;

  ArticleDetailViewModel(this._repo, this._moderationRepo);

  Insight? _insight;
  Insight? get insight => _insight;

  List<Insight> _relatedInsights = [];
  List<Insight> get relatedInsights => _relatedInsights;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaved = false;
  bool get isSaved => _isSaved;

  bool _isLiked = false;
  bool get isLiked => _isLiked;

  List<InsightComment> _comments = [];
  List<InsightComment> get comments => _comments;

  final Set<String> _likedComments = {};
  bool isCommentLiked(String commentId) => _likedComments.contains(commentId);

  Future<void> loadDetail(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repo.addView(id);
      _insight = await _repo.getInsightById(id);
      if (_insight != null) {
        _relatedInsights = await _repo.getRelatedInsights(id);

        final saved = await _repo.getSavedInsights();
        _isSaved = saved.any((item) => item.id == id);

        // Fetch likes state
        _isLiked = await _repo.isInsightLiked(id);

        _comments = await _repo.getInsightComments(id);
        _likedComments.clear();
      }
    } catch (e) {
      // error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> like() async {
    if (_insight == null) return;
    await _repo.likeInsight(_insight!.id);
    _isLiked = !_isLiked;
    // Reload metrics
    _insight = await _repo.getInsightById(_insight!.id);
    notifyListeners();
  }

  Future<void> addComment(String content) async {
    if (_insight == null || content.trim().isEmpty) return;

    final comment = InsightComment(
      id: 'ic_${DateTime.now().millisecondsSinceEpoch}',
      insightId: _insight!.id,
      username: 'user_active',
      content: content,
      createdAt: DateTime.now(),
    );

    await _repo.addInsightComment(_insight!.id, comment);
    // Reload to get updated comment count and comments
    _insight = await _repo.getInsightById(_insight!.id);
    _comments = await _repo.getInsightComments(_insight!.id);
    notifyListeners();
  }

  Future<void> likeComment(String commentId) async {
    if (_insight == null) return;
    await _repo.likeInsightComment(commentId);
    if (_likedComments.contains(commentId)) {
      _likedComments.remove(commentId);
    } else {
      _likedComments.add(commentId);
    }
    _comments = await _repo.getInsightComments(_insight!.id);
    notifyListeners();
  }

  Future<void> save() async {
    if (_insight == null) return;
    await _repo.toggleSaveInsight(_insight!.id);
    _isSaved = !_isSaved;
    _insight = await _repo.getInsightById(_insight!.id);
    notifyListeners();
  }

  Future<void> hide(BuildContext context) async {
    if (_insight == null) return;
    await _repo.hideInsight(_insight!.id);
    await _moderationRepo.recordHiddenContent(
      contentId: _insight!.id,
      title: _insight!.title,
      authorName: _insight!.authorId,
      contentSnippet: _insight!.summary,
    );
    Navigator.of(context).pop();
  }

  Future<void> report(ModerationReason reason) async {
    if (_insight == null) return;
    await _moderationRepo.reportContent(
      contentId: _insight!.id,
      title: _insight!.title,
      authorName: _insight!.authorId,
      contentSnippet: _insight!.summary,
      reason: reason,
    );
  }
}

class CreateInsightViewModel extends ChangeNotifier {
  final InsightsRepo _repo;
  Timer? _autoSaveTimer;

  CreateInsightViewModel(this._repo) {
    titleController.addListener(_onFieldChanged);
    summaryController.addListener(_onFieldChanged);
    contentController.addListener(_onFieldChanged);
  }

  final titleController = TextEditingController();
  final summaryController = TextEditingController();
  final contentController = TextEditingController();

  String _category = 'Health & Wellness';
  String get category => _category;

  String _readTime = '5 min read';
  String get readTime => _readTime;

  String _coverImage = 'assets/images/stressandsleep.png';
  String get coverImage => _coverImage;

  String _publishType = 'Publish Now'; // 'Publish Now', 'Schedule', 'Save as Draft'
  String get publishType => _publishType;

  DateTime? _scheduleDate;
  DateTime? get scheduleDate => _scheduleDate;

  bool _isFeatured = false;
  bool get isFeatured => _isFeatured;

  bool _isTrending = false;
  bool get isTrending => _isTrending;

  int _currentStep = 0; // 0: Content, 1: Details, 2: Preview
  int get currentStep => _currentStep;

  String? _activeDraftId;
  String? get activeDraftId => _activeDraftId;

  String? _existingPublishedId;
  DateTime? _existingCreatedAt;
  DateTime? _existingPublishedAt;

  bool _hasUnsavedChanges = false;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  bool _showDraftRecovery = false;
  bool get showDraftRecovery => _showDraftRecovery;

  void setCategory(String value) {
    _category = value;
    _onFieldChanged();
  }

  void setPublishType(String value) {
    _publishType = value;
    notifyListeners();
  }

  void setScheduleDate(DateTime? date) {
    _scheduleDate = date;
    notifyListeners();
  }

  void setFeatured(bool val) {
    _isFeatured = val;
    notifyListeners();
  }

  void setTrending(bool val) {
    _isTrending = val;
    notifyListeners();
  }

  void setCoverImage(String path) {
    _coverImage = path;
    _onFieldChanged();
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

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
    // Note: To properly recover without id, you might need a getDrafts() method.
    // For now we assume no active recovery if activeDraftId is unknown, 
    // or we'd fetch all drafts from repo.
    // Since getDraft takes an ID, if _activeDraftId is null, we can't fetch it easily 
    // unless we add getDrafts to repo. We'll disable this for MVP or add getDrafts later.
  }

  Future<void> restoreDraft() async {
    if (_activeDraftId == null) return;
    final draftItem = await _repo.getDraft(_activeDraftId!);
    if (draftItem != null && draftItem.type == DraftType.insightArticle) {
      final draft = Insight.fromMap(draftItem.content);
      titleController.text = draft.title;
      summaryController.text = draft.summary;
      contentController.text = draft.content;
      _category = draft.category;
      _readTime = draft.readTime;
      _coverImage = draft.coverImage;
      _isFeatured = draft.isFeatured;
      _isTrending = draft.isTrending;
      _showDraftRecovery = false;
      _hasUnsavedChanges = false;
      notifyListeners();
    }
  }

  void loadExistingInsight(Insight insight) {
    clearForm();
    if (insight.status == InsightStatus.draft) {
      _activeDraftId = insight.id;
    } else {
      _existingPublishedId = insight.id;
      _existingCreatedAt = insight.createdAt;
      _existingPublishedAt = insight.publishedAt;
    }

    titleController.text = insight.title;
    summaryController.text = insight.summary;
    contentController.text = insight.content;
    _category = insight.category;
    _readTime = insight.readTime;
    _coverImage = insight.coverImage;
    _isFeatured = insight.isFeatured;
    _isTrending = insight.isTrending;
    
    if (insight.status == InsightStatus.scheduled) {
      _publishType = 'Schedule';
      _scheduleDate = insight.publishedAt;
    } else if (insight.status == InsightStatus.published) {
      _publishType = 'Publish Now';
    }

    _hasUnsavedChanges = false;
    notifyListeners();
  }

  Future<void> discardDraft() async {
    if (_activeDraftId != null) {
      await _repo.discardDraft(_activeDraftId!);
    }
    clearForm();
  }

  Future<void> autoSaveDraft() async {
    if (titleController.text.isEmpty) return;

    final id = _activeDraftId ?? 'art_draft_${DateTime.now().millisecondsSinceEpoch}';
    _activeDraftId = id;

    final draft = Insight(
      id: id,
      title: titleController.text,
      summary: summaryController.text,
      content: contentController.text,
      coverImage: _coverImage,
      category: _category,
      readTime: _readTime,
      status: InsightStatus.draft,
      isFeatured: _isFeatured,
      isTrending: _isTrending,
      createdAt: DateTime.now(),
      authorId: 'admin_1',
    );

    final item = DraftItem(
      id: id,
      type: DraftType.insightArticle,
      content: draft.toMap(),
      updatedAt: DateTime.now(),
    );

    await _repo.saveDraft(item);
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  Future<void> publish() async {
    final isUpdate = _existingPublishedId != null;
    final id = isUpdate ? _existingPublishedId! : (_activeDraftId ?? 'art_${DateTime.now().millisecondsSinceEpoch}');

    final insight = Insight(
      id: id,
      title: titleController.text,
      summary: summaryController.text,
      content: contentController.text,
      coverImage: _coverImage,
      category: _category,
      readTime: _readTime,
      status: _publishType == 'Schedule' ? InsightStatus.scheduled : InsightStatus.published,
      isFeatured: _isFeatured,
      isTrending: _isTrending,
      createdAt: isUpdate ? _existingCreatedAt! : DateTime.now(),
      publishedAt: _publishType == 'Schedule' ? _scheduleDate : (isUpdate ? _existingPublishedAt : DateTime.now()),
      updatedAt: isUpdate ? DateTime.now() : null,
      authorId: 'admin_1',
    );

    if (isUpdate) {
      await _repo.updateInsight(insight);
    } else {
      await _repo.publishInsight(insight);
    }
    clearForm();
  }

  void clearForm() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    _existingPublishedId = null;
    _existingCreatedAt = null;
    _existingPublishedAt = null;
    _activeDraftId = null;
    titleController.clear();
    summaryController.clear();
    contentController.clear();
    _category = 'Health & Wellness';
    _readTime = '5 min read';
    _coverImage = 'assets/images/stressandsleep.png';
    _isFeatured = false;
    _isTrending = false;
    _currentStep = 0;
    _activeDraftId = null;
    _showDraftRecovery = false;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    titleController.dispose();
    summaryController.dispose();
    contentController.dispose();
    super.dispose();
  }
}

class InsightsLibraryViewModel extends ChangeNotifier {
  final InsightsRepo _repo;

  InsightsLibraryViewModel(this._repo);

  List<Insight> _insights = [];
  List<Insight> get insights => _insights;

  String _selectedTab = 'All';
  String get selectedTab => _selectedTab;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _page = 1;
    _hasMore = true;
    notifyListeners();
    loadInsights();
  }

  void setTab(String tab) {
    _selectedTab = tab;
    _page = 1;
    _hasMore = true;
    notifyListeners();
    loadInsights();
  }

  Future<void> loadInsights() async {
    _isLoading = true;
    notifyListeners();

    try {
      final all = await _repo.getAllAdminInsights();
      var filtered = all;

      if (_selectedTab != 'All') {
        final statusName = _selectedTab.toLowerCase();
        filtered = all.where((item) => item.status.name == statusName).toList();
      }

      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }

      // Sort by newest
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final startIndex = (_page - 1) * _limit;
      if (startIndex >= filtered.length) {
        _insights = [];
        _hasMore = false;
      } else {
        final endIndex = (startIndex + _limit) > filtered.length ? filtered.length : (startIndex + _limit);
        _insights = filtered.sublist(startIndex, endIndex);
        _hasMore = (startIndex + _limit) < filtered.length;
      }
    } catch (e) {
      // error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> archiveInsight(String id) async {
    await _repo.archiveInsight(id);
    await loadInsights();
  }

  Future<void> deleteInsight(String id) async {
    await _repo.deleteInsight(id);
    await loadInsights();
  }

  Future<void> duplicateInsight(String id) async {
    await _repo.duplicateInsight(id);
    await loadInsights();
  }

  void nextPage() {
    if (!_hasMore) return;
    _page++;
    loadInsights();
  }

  void prevPage() {
    if (_page <= 1) return;
    _page--;
    loadInsights();
  }

  int get currentPage => _page;
}
