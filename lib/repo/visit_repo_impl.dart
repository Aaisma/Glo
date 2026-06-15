import '../model/visit_model.dart';
import '../services/visits_service.dart';
import 'visit_repo.dart';

class VisitRepoImpl implements VisitRepo {
  final VisitsService _service = VisitsService();

  @override
  Future<void> addVisit(VisitModel visit, String userId) {
    return _service.addVisit(visit, userId);
  }

  @override
  Future<List<VisitModel>> getVisits(String userId) {
    return _service.getVisits(userId);
  }

  @override
  Future<void> updateVisit(VisitModel visit) {
    return _service.updateVisit(visit);
  }

  @override
  Future<void> deleteVisit(String id) {
    return _service.deleteVisit(id);
  }
}
