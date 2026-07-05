import 'package:flutter/material.dart';
import '../repo/admin_monthly_tracking_repo.dart';

enum DateFilter { today, last7Days, last30Days, last3Months, last6Months, lastYear, custom }

class AdminMonthlyTrackingViewModel extends ChangeNotifier {
  final AdminMonthlyTrackingRepo _repo;

  AdminMonthlyTrackingViewModel(this._repo);

  bool isLoading = false;
  String? errorMessage;

  DateFilter currentFilter = DateFilter.last30Days;
  DateTime? customStartDate;
  DateTime? customEndDate;

  // Period Data
  Map<String, dynamic> periodAnalytics = {};
  
  // Ovulation Data
  Map<String, dynamic> ovulationAnalytics = {};
  
  // Symptoms Data
  Map<String, dynamic> symptomsAnalytics = {};
  
  // Symptoms Details
  String selectedSymptom = 'Cramps';
  List<String> availableSymptoms = ['Cramps', 'Bloating', 'Headache', 'Fatigue', 'Tender Breasts'];
  Map<String, dynamic> symptomsDetails = {};

  // Calendar
  DateTime selectedCalendarDate = DateTime.now();
  Map<String, dynamic> calendarSummary = {};

  DateTime get startDate {
    final now = DateTime.now();
    switch (currentFilter) {
      case DateFilter.today: return DateTime(now.year, now.month, now.day);
      case DateFilter.last7Days: return now.subtract(const Duration(days: 7));
      case DateFilter.last30Days: return now.subtract(const Duration(days: 30));
      case DateFilter.last3Months: return now.subtract(const Duration(days: 90));
      case DateFilter.last6Months: return now.subtract(const Duration(days: 180));
      case DateFilter.lastYear: return now.subtract(const Duration(days: 365));
      case DateFilter.custom: return customStartDate ?? now.subtract(const Duration(days: 30));
    }
  }

  DateTime get endDate {
    if (currentFilter == DateFilter.custom) {
      return customEndDate ?? DateTime.now();
    }
    return DateTime.now();
  }
  
  String get dateRangeText {
    // Basic formatting, could use intl package
    return "${startDate.month}/${startDate.day}/${startDate.year} - ${endDate.month}/${endDate.day}/${endDate.year}";
  }

  void setDateFilter(DateFilter filter, {DateTime? start, DateTime? end}) {
    currentFilter = filter;
    if (filter == DateFilter.custom) {
      customStartDate = start;
      customEndDate = end;
    }
    loadAllAnalytics();
  }

  void setSelectedSymptom(String symptom) {
    selectedSymptom = symptom;
    loadSymptomsDetails();
  }
  
  void setCalendarDate(DateTime date) {
    selectedCalendarDate = date;
    loadCalendarSummary();
  }

  Future<void> loadAllAnalytics() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final periodFuture = _repo.getPeriodAnalytics(startDate, endDate);
      final ovulationFuture = _repo.getOvulationAnalytics(startDate, endDate);
      final symptomsFuture = _repo.getSymptomsAnalytics(startDate, endDate);
      
      final results = await Future.wait([periodFuture, ovulationFuture, symptomsFuture]);
      
      periodAnalytics = results[0];
      ovulationAnalytics = results[1];
      symptomsAnalytics = results[2];
      
      // Update available symptoms based on top symptoms
      if (symptomsAnalytics['topSymptoms'] != null) {
        availableSymptoms = (symptomsAnalytics['topSymptoms'] as List)
            .map((e) => e.key as String)
            .toList();
        if (!availableSymptoms.contains(selectedSymptom) && availableSymptoms.isNotEmpty) {
          selectedSymptom = availableSymptoms.first;
        }
      }

      await loadSymptomsDetails();
      await loadCalendarSummary();
    } catch (e) {
      errorMessage = "Failed to load tracking analytics: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSymptomsDetails() async {
    try {
      symptomsDetails = await _repo.getSymptomsDetails(selectedSymptom, startDate, endDate);
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading symptom details: $e");
    }
  }

  Future<void> loadCalendarSummary() async {
    try {
      calendarSummary = await _repo.getCalendarDailySummary(selectedCalendarDate);
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading calendar summary: $e");
    }
  }
}
