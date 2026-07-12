import '../model/health_overview_model.dart';

abstract class AdminHealthOverviewRepo {
  Future<HealthOverviewData> fetchOverview();
}