// lib/repo/admin_health_overview_repo.dart
import '../model/health_overview_model.dart';

abstract class AdminHealthOverviewRepo {
  Future<HealthOverviewData> fetchOverview();
}
