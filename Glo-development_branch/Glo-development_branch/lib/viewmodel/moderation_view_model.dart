import 'package:flutter/material.dart';
import '../model/community_models.dart';
import '../repo/insights_moderation_repo.dart';
import '../repo/community_moderation_repo.dart';

class InsightsModerationQueueViewModel extends ChangeNotifier {
  final InsightsModerationRepo _repo;

  InsightsModerationQueueViewModel(this._repo);

  List<ModerationItem> _reportedItems = [];
  List<ModerationItem> get reportedItems => _reportedItems;

  List<ModerationItem> _hiddenItems = [];
  List<ModerationItem> get hiddenItems => _hiddenItems;

  String _selectedTab = 'Reported'; // 'Reported', 'Hidden'
  String get selectedTab => _selectedTab;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  void setTab(String tab) {
    _selectedTab = tab;
    _page = 1;
    _hasMore = true;
    notifyListeners();
    loadQueue();
  }

  Future<void> loadQueue() async {
    _isLoading = true;
    notifyListeners();

    try {
      final all = await _repo.getModerationQueue(
        page: 1,
        limit: 100,
        isArchived: false,
      );

      _reportedItems = all.where((e) => e.reportsCount > 0).toList();
      _hiddenItems = all.where((e) => e.hiddenCount > 0).toList();

      final activeList = _selectedTab == 'Reported' ? _reportedItems : _hiddenItems;
      final startIndex = (_page - 1) * _limit;
      
      _hasMore = (startIndex + _limit) < activeList.length;
    } catch (e) {
      // error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> archiveItem(String id) async {
    await _repo.archiveModerationItem(id);
    await loadQueue();
  }

  Future<void> softDeleteItem(String id) async {
    await _repo.softDeleteContent(id);
    await loadQueue();
  }

  void nextPage() {
    if (!_hasMore) return;
    _page++;
    loadQueue();
  }

  void prevPage() {
    if (_page <= 1) return;
    _page--;
    loadQueue();
  }

  int get currentPage => _page;

  int get reportedCount => _reportedItems.length;
  int get hiddenCount => _hiddenItems.length;
}

class InsightsModerationDetailViewModel extends ChangeNotifier {
  final InsightsModerationRepo _repo;

  InsightsModerationDetailViewModel(this._repo);

  ModerationItem? _moderationItem;
  ModerationItem? get moderationItem => _moderationItem;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<ModerationReason, int> get reasonBreakdown {
    if (_moderationItem == null) return {};
    final breakdown = <ModerationReason, int>{};
    for (var r in _moderationItem!.reasons) {
      breakdown[r] = (breakdown[r] ?? 0) + 1;
    }
    if (_moderationItem!.reportsCount > 1 && breakdown.isNotEmpty) {
      final mainReason = _moderationItem!.reasons.first;
      breakdown[mainReason] = _moderationItem!.reportsCount;
    }
    return breakdown;
  }

  Future<void> loadDetail(String contentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _moderationItem = await _repo.getModerationDetail(contentId);
    } catch (e) {
      // error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> archiveContent(BuildContext context) async {
    if (_moderationItem == null) return false;
    await _repo.archiveModerationItem(_moderationItem!.id);
    return true;
  }

  Future<bool> softDeleteContent(BuildContext context) async {
    if (_moderationItem == null) return false;
    await _repo.softDeleteContent(_moderationItem!.id);
    return true;
  }
}

class CommunityModerationQueueViewModel extends ChangeNotifier {
  final CommunityModerationRepo _repo;

  CommunityModerationQueueViewModel(this._repo);

  List<ModerationItem> _reportedItems = [];
  List<ModerationItem> get reportedItems => _reportedItems;

  List<ModerationItem> _hiddenItems = [];
  List<ModerationItem> get hiddenItems => _hiddenItems;

  String _selectedTab = 'Reported';
  String get selectedTab => _selectedTab;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  void setTab(String tab) {
    _selectedTab = tab;
    _page = 1;
    _hasMore = true;
    notifyListeners();
    loadQueue();
  }

  Future<void> loadQueue() async {
    _isLoading = true;
    notifyListeners();

    try {
      final all = await _repo.getModerationQueue(
        page: 1,
        limit: 100,
        isArchived: false,
      );

      _reportedItems = all.where((e) => e.reportsCount > 0).toList();
      _hiddenItems = all.where((e) => e.hiddenCount > 0).toList();

      final activeList = _selectedTab == 'Reported' ? _reportedItems : _hiddenItems;
      final startIndex = (_page - 1) * _limit;
      
      _hasMore = (startIndex + _limit) < activeList.length;
    } catch (e) {
      // error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> archiveItem(String id) async {
    await _repo.archiveModerationItem(id);
    await loadQueue();
  }

  Future<void> softDeleteItem(String id) async {
    await _repo.softDeleteContent(id);
    await loadQueue();
  }

  void nextPage() {
    if (!_hasMore) return;
    _page++;
    loadQueue();
  }

  void prevPage() {
    if (_page <= 1) return;
    _page--;
    loadQueue();
  }

  int get currentPage => _page;

  int get reportedCount => _reportedItems.length;
  int get hiddenCount => _hiddenItems.length;
}

class CommunityModerationDetailViewModel extends ChangeNotifier {
  final CommunityModerationRepo _repo;

  CommunityModerationDetailViewModel(this._repo);

  ModerationItem? _moderationItem;
  ModerationItem? get moderationItem => _moderationItem;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<ModerationReason, int> get reasonBreakdown {
    if (_moderationItem == null) return {};
    final breakdown = <ModerationReason, int>{};
    for (var r in _moderationItem!.reasons) {
      breakdown[r] = (breakdown[r] ?? 0) + 1;
    }
    if (_moderationItem!.reportsCount > 1 && breakdown.isNotEmpty) {
      final mainReason = _moderationItem!.reasons.first;
      breakdown[mainReason] = _moderationItem!.reportsCount;
    }
    return breakdown;
  }

  Future<void> loadDetail(String contentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _moderationItem = await _repo.getModerationDetail(contentId);
    } catch (e) {
      // error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> archiveContent(BuildContext context) async {
    if (_moderationItem == null) return false;
    await _repo.archiveModerationItem(_moderationItem!.id);
    return true;
  }

  Future<bool> softDeleteContent(BuildContext context) async {
    if (_moderationItem == null) return false;
    await _repo.softDeleteContent(_moderationItem!.id);
    return true;
  }
}
