import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsRepoImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalAcneEntries() async {
    final snapshot = await _firestore.collectionGroup('acne_tracker').get();
    return snapshot.docs.length;
  }

  Future<int> getTotalWaterEntries() async {
    final snapshot = await _firestore.collectionGroup('water_history').get();
    return snapshot.docs.length;
  }

  Future<Map<String, int>> getAcneSeverityDistribution() async {
    final snapshot = await _firestore.collectionGroup('acne_tracker').get();
    final Map<String, int> counts = {"Clear": 0, "Mild": 0, "Moderate": 0, "Severe": 0};
    for (final doc in snapshot.docs) {
      final severity = doc.data()['severity'] as String? ?? "Unknown";
      if (counts.containsKey(severity)) {
        counts[severity] = counts[severity]! + 1;
      }
    }
    return counts;
  }

  Future<double> getAverageWaterGoalCompletion() async {
    final snapshot = await _firestore.collectionGroup('water_history').get();
    if (snapshot.docs.isEmpty) return 0;
    double totalPercent = 0;
    int count = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final intake = (data['intake'] as num?)?.toDouble();
      final goal = (data['goal'] as num?)?.toDouble();
      if (intake != null && goal != null && goal > 0) {
        totalPercent += (intake / goal).clamp(0, 1.5);
        count++;
      }
    }
    return count == 0 ? 0 : (totalPercent / count) * 100;
  }

  Future<double> getAverageWaterIntake() async {
    final snapshot = await _firestore.collectionGroup('water_history').get();
    if (snapshot.docs.isEmpty) return 0;
    double total = 0;
    int count = 0;
    for (final doc in snapshot.docs) {
      final intake = (doc.data()['intake'] as num?)?.toDouble();
      if (intake != null) {
        total += intake;
        count++;
      }
    }
    return count == 0 ? 0 : total / count;
  }

  Future<Map<String, double>> getSeverityTrendLast7Days() async {
    final snapshot = await _firestore.collectionGroup('acne_tracker').get();
    const severityScore = {"Clear": 0.0, "Mild": 1.0, "Moderate": 2.0, "Severe": 3.0};

    final Map<String, List<double>> byDate = {};
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final key = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      byDate[key] = [];
    }

    for (final doc in snapshot.docs) {
      final date = doc.data()['date'] as String?;
      final severity = doc.data()['severity'] as String?;
      if (date != null && byDate.containsKey(date) && severity != null && severityScore.containsKey(severity)) {
        byDate[date]!.add(severityScore[severity]!);
      }
    }

    final Map<String, double> avgByDate = {};
    byDate.forEach((date, scores) {
      avgByDate[date] = scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;
    });

    return avgByDate;
  }

  Future<double> getSevereCaseWeekOverWeekChange() async {
    final snapshot = await _firestore.collectionGroup('acne_tracker').get();
    final today = DateTime.now();

    int thisWeekSevere = 0;
    int lastWeekSevere = 0;

    for (final doc in snapshot.docs) {
      final dateStr = doc.data()['date'] as String?;
      final severity = doc.data()['severity'] as String?;
      if (dateStr == null || severity != "Severe") continue;
      try {
        final date = DateTime.parse(dateStr);
        final daysAgo = today.difference(date).inDays;
        if (daysAgo >= 0 && daysAgo < 7) {
          thisWeekSevere++;
        } else if (daysAgo >= 7 && daysAgo < 14) {
          lastWeekSevere++;
        }
      } catch (_) {}
    }

    if (lastWeekSevere == 0) {
      return thisWeekSevere > 0 ? 100 : 0;
    }
    return ((thisWeekSevere - lastWeekSevere) / lastWeekSevere) * 100;
  }

  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    final snapshot = await _firestore.collectionGroup('acne_tracker').get();
    final Map<String, int> counts = {};

    for (final doc in snapshot.docs) {
      final products = doc.data()['products'] as List<dynamic>? ?? [];
      for (final p in products) {
        final name = (p as Map<String, dynamic>)['name'] as String?;
        if (name != null && name.isNotEmpty) {
          counts[name] = (counts[name] ?? 0) + 1;
        }
      }
    }

    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => {"name": e.key, "count": e.value}).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentAcneEntries({int limit = 5}) async {
    final snapshot = await _firestore.collectionGroup('acne_tracker').get();
    final docs = snapshot.docs.toList()
      ..sort((a, b) => ((b.data()['date'] as String?) ?? '').compareTo((a.data()['date'] as String?) ?? ''));
    return docs.take(limit).map((doc) {
      final userId = doc.reference.parent.parent?.id ?? "unknown";
      return {
        "userId": userId,
        "date": doc.data()['date'],
        "severity": doc.data()['severity'],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getLowestIntakeUsers({int limit = 5}) async {
    final snapshot = await _firestore.collectionGroup('water_history').get();
    final Map<String, List<double>> intakeByUser = {};
    final Map<String, List<double>> goalByUser = {};

    for (final doc in snapshot.docs) {
      final userId = doc.reference.parent.parent?.id ?? "unknown";
      final intake = (doc.data()['intake'] as num?)?.toDouble();
      final goal = (doc.data()['goal'] as num?)?.toDouble();
      if (intake != null) intakeByUser.putIfAbsent(userId, () => []).add(intake);
      if (goal != null) goalByUser.putIfAbsent(userId, () => []).add(goal);
    }

    final results = intakeByUser.entries.map((e) {
      final avgIntake = e.value.reduce((a, b) => a + b) / e.value.length;
      final goals = goalByUser[e.key];
      final avgGoal = (goals != null && goals.isNotEmpty) ? goals.reduce((a, b) => a + b) / goals.length : 0.0;
      return {"userId": e.key, "avgIntake": avgIntake, "avgGoal": avgGoal};
    }).toList();

    results.sort((a, b) => (a["avgIntake"] as double).compareTo(b["avgIntake"] as double));
    return results.take(limit).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentWaterEntries({int limit = 5}) async {
    final snapshot = await _firestore.collectionGroup('water_history').get();
    final docs = snapshot.docs.toList()
      ..sort((a, b) => ((b.data()['date'] as String?) ?? '').compareTo((a.data()['date'] as String?) ?? ''));
    return docs.take(limit).map((doc) {
      final userId = doc.reference.parent.parent?.id ?? "unknown";
      return {
        "userId": userId,
        "date": doc.data()['date'],
        "intake": doc.data()['intake'],
      };
    }).toList();
  }

  Future<Map<String, double>> getWaterIntakeTrendLast7Days() async {
    final snapshot = await _firestore.collectionGroup('water_history').get();
    final Map<String, List<double>> byDate = {};
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final key = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      byDate[key] = [];
    }

    for (final doc in snapshot.docs) {
      final date = doc.data()['date'] as String?;
      final intake = (doc.data()['intake'] as num?)?.toDouble();
      if (date != null && byDate.containsKey(date) && intake != null) {
        byDate[date]!.add(intake);
      }
    }

    final Map<String, double> avgByDate = {};
    byDate.forEach((date, values) {
      avgByDate[date] = values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
    });
    return avgByDate;
  }

  Future<int> getDistinctAcneUsers() async {
    final snapshot = await _firestore.collectionGroup('acne_tracker').get();
    final ids = snapshot.docs.map((d) => d.reference.parent.parent?.id ?? '').toSet();
    return ids.length;
  }

  Future<int> getDistinctWaterUsers() async {
    final snapshot = await _firestore.collectionGroup('water_history').get();
    final ids = snapshot.docs.map((d) => d.reference.parent.parent?.id ?? '').toSet();
    return ids.length;
  }

  String _todayKey() {
    final today = DateTime.now();
    return "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  }

  Future<int> getTodayAcneEntries() async {
    final snapshot = await _firestore.collectionGroup('acne_tracker').get();
    return snapshot.docs.where((d) => d.data()['date'] == _todayKey()).length;
  }

  Future<int> getTodayWaterEntries() async {
    final snapshot = await _firestore.collectionGroup('water_history').get();
    return snapshot.docs.where((d) => d.data()['date'] == _todayKey()).length;
  }

  Future<double> getAverageChecklistCompletion() async {
    final snapshot = await _firestore.collectionGroup('acne_tracker').get();
    if (snapshot.docs.isEmpty) return 0;
    const totalTasks = 4;
    double total = 0;
    for (final doc in snapshot.docs) {
      final checklist = doc.data()['checklist'] as List<dynamic>? ?? [];
      total += checklist.length / totalTasks;
    }
    return (total / snapshot.docs.length) * 100;
  }

  Future<int> getUsersMetGoalToday() async {
    final snapshot = await _firestore.collectionGroup('water_history').get();
    final todayKey = _todayKey();
    int count = 0;
    for (final doc in snapshot.docs) {
      if (doc.data()['date'] != todayKey) continue;
      final intake = (doc.data()['intake'] as num?)?.toDouble();
      final goal = (doc.data()['goal'] as num?)?.toDouble();
      if (intake != null && goal != null && intake >= goal) count++;
    }
    return count;
  }
}