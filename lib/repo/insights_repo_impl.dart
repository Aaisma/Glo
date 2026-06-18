import 'package:hive/hive.dart';
import '../model/insight_models.dart';
import '../model/shared_models.dart';
import 'insights_repo.dart';

class InsightsRepoImpl implements InsightsRepo {
  final Box _insightsBox;
  final Box _draftsBox;

  InsightsRepoImpl({Box? insightsBox, Box? draftsBox})
      : _insightsBox = insightsBox ?? Hive.box('insights_box'),
        _draftsBox = draftsBox ?? Hive.box('drafts_box') {
    _initMockData();
  }

  void _initMockData() {
    if (_insightsBox.isEmpty) {
      final now = DateTime.now();
      final mocks = [
        Insight(
          id: 'art_1',
          title: 'Morning Rituals That Set a Positive Tone',
          summary: 'Simple morning habits that boost your mood, energy, and focus all day long.',
          content: 'Starting your day with intention can set the tone for everything that follows. In this article, we explore simple yet powerful morning rituals that can positively impact your mindset, productivity, and overall well-being.\n\nWhether you are an early riser or not, these habits are easy to adopt and can make a big difference over time.\n\n1. Hydrate first: Drink a glass of warm water with lemon to wake up your digestive system.\n2. Light stretch: Move your body for 5-10 minutes to release morning stiffness.\n3. Mindfulness: Take 5 deep breaths and write down three things you are grateful for today.',
          coverImage: 'assets/images/stressandsleep.png',
          category: 'Health & Wellness',
          readTime: '5 min read',
          status: InsightStatus.published,
          isFeatured: true,
          isTrending: false,
          createdAt: now.subtract(const Duration(days: 3)),
          publishedAt: now.subtract(const Duration(days: 3)),
          authorId: 'admin_1',
          views: 120,
          likes: 24,
          saves: 15,
          shares: 10,
        ),
        Insight(
          id: 'art_2',
          title: 'The Power of Boundaries',
          summary: 'Learn how setting boundaries can protect your peace and improve your relationships.',
          content: 'Boundaries are essential for healthy living. Setting clear boundaries helps you manage your energy, focus on your goals, and establish mutually respectful relationships. We discuss the types of boundaries, how to communicate them with empathy and strength, and ways to handle pushback from others.',
          coverImage: 'assets/images/aboutus.png',
          category: 'Lifestyle',
          readTime: '6 min read',
          status: InsightStatus.published,
          isFeatured: false,
          isTrending: true,
          createdAt: now.subtract(const Duration(days: 2)),
          publishedAt: now.subtract(const Duration(days: 2)),
          authorId: 'admin_1',
          views: 95,
          likes: 18,
          saves: 8,
          shares: 5,
        ),
        Insight(
          id: 'art_3',
          title: 'Building a Support System That Lasts',
          summary: 'Surround yourself with people who uplift, inspire, and truly have your back.',
          content: 'No one is an island. Constructing a supportive network of family, friends, mentors, and peers is vital for personal growth. Learn how to identify positive people, establish vulnerability, and nurture long-term relationships that support your well-being.',
          coverImage: 'assets/images/logo.png',
          category: 'Community',
          readTime: '4 min read',
          status: InsightStatus.published,
          isFeatured: false,
          isTrending: false,
          createdAt: now.subtract(const Duration(days: 1)),
          publishedAt: now.subtract(const Duration(days: 1)),
          authorId: 'admin_2',
          views: 75,
          likes: 14,
          saves: 12,
          shares: 4,
        ),
        Insight(
          id: 'art_4',
          title: 'Mindfulness and Mental Health',
          summary: 'Daily meditation and breathing exercises to manage stress and anxiety.',
          content: 'Taking just ten minutes every day to sit in silence and focus on your breathing can significantly lower your cortisol levels. Discover the science behind meditation, simple techniques for beginners, and apps to help keep you on track.',
          coverImage: 'assets/images/journal.png',
          category: 'Expert Insights',
          readTime: '7 min read',
          status: InsightStatus.published,
          isFeatured: false,
          isTrending: true,
          createdAt: now.subtract(const Duration(hours: 12)),
          publishedAt: now.subtract(const Duration(hours: 12)),
          authorId: 'admin_3',
          views: 230,
          likes: 42,
          saves: 33,
          shares: 18,
        ),
        Insight(
          id: 'art_5',
          title: 'Understanding Hormonal Balance',
          summary: 'A look into how your menstrual cycle affects your body and mood.',
          content: 'Hormones affect everything from sleep cycles and energy to skin conditions and mental health. This article covers simple diet changes, supplements, and lifestyle habits that promote healthy hormone levels throughout the month.',
          coverImage: 'assets/images/skinderma.png',
          category: 'Health & Wellness',
          readTime: '8 min read',
          status: InsightStatus.published,
          isFeatured: false,
          isTrending: false,
          createdAt: now.subtract(const Duration(hours: 4)),
          publishedAt: now.subtract(const Duration(hours: 4)),
          authorId: 'admin_1',
          views: 180,
          likes: 31,
          saves: 22,
          shares: 9,
        ),
      ];

      for (var mock in mocks) {
        _insightsBox.put(mock.id, mock.toMap());
      }
    }
  }

  @override
  Future<List<Insight>> getInsights({
    required int page,
    required int limit,
    String? query,
    String? category,
  }) async {
    // Read all values from Box
    final allItems = _insightsBox.values
        .map((e) => Insight.fromMap(Map<String, dynamic>.from(e)))
        .where((e) => !e.isDeleted && e.status == InsightStatus.published)
        .toList();

    // Sort: newest first
    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Filter by query (title, summary, or content)
    var filtered = allItems;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((item) =>
          item.title.toLowerCase().contains(q) ||
          item.summary.toLowerCase().contains(q) ||
          item.content.toLowerCase().contains(q)).toList();
    }

    // Filter by category
    if (category != null && category.trim().isNotEmpty && category != 'Trending') {
      filtered = filtered.where((item) => item.category.toLowerCase() == category.toLowerCase()).toList();
    } else if (category == 'Trending') {
      filtered = filtered.where((item) => item.isTrending).toList();
    }

    // Pagination
    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) {
      return [];
    }
    final endIndex = (startIndex + limit) > filtered.length ? filtered.length : (startIndex + limit);
    return filtered.sublist(startIndex, endIndex);
  }

  @override
  Future<Insight?> getFeaturedInsight() async {
    final allItems = _insightsBox.values
        .map((e) => Insight.fromMap(Map<String, dynamic>.from(e)))
        .where((e) => !e.isDeleted && e.status == InsightStatus.published && e.isFeatured)
        .toList();
    if (allItems.isEmpty) return null;
    allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allItems.first;
  }

  @override
  Future<Insight?> getInsightById(String id) async {
    final data = _insightsBox.get(id);
    if (data == null) return null;
    final insight = Insight.fromMap(Map<String, dynamic>.from(data));
    return insight.isDeleted ? null : insight;
  }

  @override
  Future<List<Insight>> getRelatedInsights(String insightId) async {
    final original = await getInsightById(insightId);
    if (original == null) return [];

    final allItems = _insightsBox.values
        .map((e) => Insight.fromMap(Map<String, dynamic>.from(e)))
        .where((e) => !e.isDeleted && e.status == InsightStatus.published && e.id != insightId)
        .toList();

    // Try finding in same category first
    var related = allItems.where((e) => e.category == original.category).toList();
    if (related.length < 3) {
      // Pad with others
      final others = allItems.where((e) => e.category != original.category).toList();
      related.addAll(others);
    }

    // Return minimum 3 recommendations or all available up to 5
    if (related.length > 5) {
      return related.sublist(0, 5);
    }
    return related;
  }

  @override
  Future<void> toggleSaveInsight(String id) async {
    final data = _insightsBox.get(id);
    if (data != null) {
      final insight = Insight.fromMap(Map<String, dynamic>.from(data));
      
      // We will handle favorites by adding the ID to a list of favorites in Hive
      final favoritesBox = Hive.box('insights_box');
      List<String> favIds = List<String>.from(favoritesBox.get('saved_insight_ids', defaultValue: <String>[]));
      
      int savesDiff = 0;
      if (favIds.contains(id)) {
        favIds.remove(id);
        savesDiff = -1;
      } else {
        favIds.add(id);
        savesDiff = 1;
      }
      await favoritesBox.put('saved_insight_ids', favIds);

      // Also update the saves count in the Insight itself
      final updated = insight.copyWith(saves: (insight.saves + savesDiff).clamp(0, 999999));
      await _insightsBox.put(id, updated.toMap());
    }
  }

  @override
  Future<List<Insight>> getSavedInsights() async {
    List<String> favIds = List<String>.from(_insightsBox.get('saved_insight_ids', defaultValue: <String>[]));
    final result = <Insight>[];
    for (var id in favIds) {
      final ins = await getInsightById(id);
      if (ins != null) {
        result.add(ins);
      }
    }
    return result;
  }

  @override
  @override
  Future<void> saveDraft(DraftItem draft) async {
    await _draftsBox.put(draft.id, draft.toMap());
  }

  @override
  Future<DraftItem?> getDraft(String id) async {
    final data = _draftsBox.get(id);
    if (data == null) return null;
    return DraftItem.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> discardDraft(String id) async {
    await _draftsBox.delete(id);
  }

  @override
  Future<void> publishInsight(Insight insight) async {
    // If it was a draft, delete from drafts
    await _draftsBox.delete(insight.id);

    // Save to insights
    final now = DateTime.now();
    final published = insight.copyWith(
      status: InsightStatus.published,
      publishedAt: now,
      createdAt: insight.createdAt, // keep creation time
    );
    await _insightsBox.put(published.id, published.toMap());
  }

  @override
  Future<void> archiveInsight(String id) async {
    final data = _insightsBox.get(id);
    if (data != null) {
      final insight = Insight.fromMap(Map<String, dynamic>.from(data));
      final updated = insight.copyWith(status: InsightStatus.archived);
      await _insightsBox.put(id, updated.toMap());
    }
  }

  @override
  Future<void> duplicateInsight(String id) async {
    final data = _insightsBox.get(id);
    if (data != null) {
      final original = Insight.fromMap(Map<String, dynamic>.from(data));
      final newId = 'art_${DateTime.now().millisecondsSinceEpoch}';
      final duplicate = original.copyWith(
        id: newId,
        title: '${original.title} (Copy)',
        createdAt: DateTime.now(),
        status: InsightStatus.draft,
        views: 0,
        likes: 0,
        saves: 0,
        shares: 0,
      );
      final item = DraftItem(
        id: newId,
        type: DraftType.insightArticle,
        content: duplicate.toMap(),
        updatedAt: DateTime.now(),
      );
      await _draftsBox.put(newId, item.toMap());
    }
  }

  @override
  Future<List<Insight>> getAllAdminInsights() async {
    return _insightsBox.values
        .map((e) => Insight.fromMap(Map<String, dynamic>.from(e)))
        .where((e) => !e.isDeleted)
        .toList();
  }

  @override
  Future<void> addView(String id) async {
    final data = _insightsBox.get(id);
    if (data != null) {
      final original = Insight.fromMap(Map<String, dynamic>.from(data));
      final updated = original.copyWith(views: original.views + 1);
      await _insightsBox.put(id, updated.toMap());
    }
  }

  @override
  Future<void> likeInsight(String id) async {
    final data = _insightsBox.get(id);
    if (data != null) {
      final original = Insight.fromMap(Map<String, dynamic>.from(data));
      
      final likesBox = Hive.box('insights_box');
      List<String> likedIds = List<String>.from(likesBox.get('liked_insight_ids', defaultValue: <String>[]));
      
      int likesDiff = 0;
      if (likedIds.contains(id)) {
        likedIds.remove(id);
        likesDiff = -1;
      } else {
        likedIds.add(id);
        likesDiff = 1;
      }
      await likesBox.put('liked_insight_ids', likedIds);

      final updated = original.copyWith(likes: (original.likes + likesDiff).clamp(0, 999999));
      await _insightsBox.put(id, updated.toMap());
    }
  }
}
