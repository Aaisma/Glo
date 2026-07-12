import '../model/health_overview_model.dart';
import 'admin_health_overview_repo.dart';

class AdminHealthOverviewRepoImpl implements AdminHealthOverviewRepo {
  @override
  Future<HealthOverviewData> fetchOverview() async {
    // Temporary result until Firestore/API logic is added.
    return HealthOverviewData.empty();
  }
}