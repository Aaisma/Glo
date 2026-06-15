import '../model/visit_model.dart';

abstract class VisitRepo {
  Future<void> addVisit(VisitModel visit, String userId);
  Future<List<VisitModel>> getVisits(String userId);
  Future<void> updateVisit(VisitModel visit);
  Future<void> deleteVisit(String id);
}
