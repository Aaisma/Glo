import 'package:flutter/material.dart';
import '../model/visit_model.dart';
import '../repo/visit_repo.dart';
import '../repo/visit_repo_impl.dart';

class VisitViewModel extends ChangeNotifier {
  final VisitRepo _repo = VisitRepoImpl();

  List<VisitModel> _visits = [];
  bool _loading = false;
  String? _error;

  List<VisitModel> get visits => _visits;
  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _setVisits(List<VisitModel> value) {
    _visits = value;
    notifyListeners();
  }

  Future<void> fetchVisits(String userId) async {
    _setLoading(true);
    try {
      final data = await _repo.getVisits(userId);
      _setVisits(data);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addVisit(VisitModel visit, String userId) async {
    _setLoading(true);
    try {
      await _repo.addVisit(visit, userId);
      await fetchVisits(userId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateVisit(VisitModel visit, String userId) async {
    _setLoading(true);
    try {
      await _repo.updateVisit(visit);
      await fetchVisits(userId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteVisit(String id, String userId) async {
    _setLoading(true);
    try {
      await _repo.deleteVisit(id);
      await fetchVisits(userId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
