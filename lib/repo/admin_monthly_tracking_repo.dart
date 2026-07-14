
abstract class AdminMonthlyTrackingRepo {
  Future<Map<String, dynamic>> getPeriodAnalytics(DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getOvulationAnalytics(DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getSymptomsAnalytics(DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getSymptomsDetails(String symptom, DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getCalendarDailySummary(DateTime date);
  Future<Map<String, Map<String, dynamic>>> getCalendarMonthSummary(DateTime monthStart, DateTime monthEndExclusive);
}

