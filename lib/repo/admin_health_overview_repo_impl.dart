// lib/repo/admin_health_overview_repo_impl.dart
import '../model/health_overview_model.dart';
import 'admin_health_overview_repo.dart';

class AdminHealthOverviewRepoImpl implements AdminHealthOverviewRepo {
  @override
  Future<HealthOverviewData> fetchOverview() async {
    // TODO: Replace with Firestore or API call
    await Future.delayed(const Duration(seconds: 1));
    return HealthOverviewData.empty();
  }
}
