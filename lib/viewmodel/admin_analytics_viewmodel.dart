import 'package:flutter/material.dart';
import '../repo/admin_analytics_repo_impl.dart';

class AdminAnalyticsViewModel extends ChangeNotifier {
  final AdminAnalyticsRepoImpl _repo;

  AdminAnalyticsViewModel(this._repo);

  bool isLoading = false;
  String? errorMessage;

  int acneEntries = 0;
  int waterEntries = 0;
  Map<String, int> severityDistribution = {"Clear": 0, "Mild": 0, "Moderate": 0, "Severe": 0};
  double waterGoalCompletion = 0;
  double averageWaterIntake = 0;
  Map<String, double> severityTrend = {};
  Map<String, double> waterIntakeTrend = {};
  double severeChangePercent = 0;
  List<Map<String, dynamic>> topProducts = [];
  List<Map<String, dynamic>> recentAcneEntries = [];
  List<Map<String, dynamic>> lowestIntakeUsers = [];
  List<Map<String, dynamic>> recentWaterEntries = [];

  int distinctAcneUsers = 0;
  int distinctWaterUsers = 0;
  int todayAcneEntries = 0;
  int todayWaterEntries = 0;
  double averageChecklistCompletion = 0;
  int usersMetGoalToday = 0;

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      acneEntries = await _repo.getTotalAcneEntries();
      waterEntries = await _repo.getTotalWaterEntries();
      severityDistribution = await _repo.getAcneSeverityDistribution();
      waterGoalCompletion = await _repo.getAverageWaterGoalCompletion();
      averageWaterIntake = await _repo.getAverageWaterIntake();
      severityTrend = await _repo.getSeverityTrendLast7Days();
      waterIntakeTrend = await _repo.getWaterIntakeTrendLast7Days();
      severeChangePercent = await _repo.getSevereCaseWeekOverWeekChange();
      topProducts = await _repo.getTopProducts();
      recentAcneEntries = await _repo.getRecentAcneEntries();
      lowestIntakeUsers = await _repo.getLowestIntakeUsers();
      recentWaterEntries = await _repo.getRecentWaterEntries();
      distinctAcneUsers = await _repo.getDistinctAcneUsers();
      distinctWaterUsers = await _repo.getDistinctWaterUsers();
      todayAcneEntries = await _repo.getTodayAcneEntries();
      todayWaterEntries = await _repo.getTodayWaterEntries();
      averageChecklistCompletion = await _repo.getAverageChecklistCompletion();
      usersMetGoalToday = await _repo.getUsersMetGoalToday();
    } catch (e) {
      errorMessage = "Failed to load analytics: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String maskId(String id) => id.length > 4 ? "•••${id.substring(id.length - 4)}" : id;
}