import 'package:flutter/material.dart';
import '../model/health_model.dart';
import '../repo/health_repo.dart';
import '../repo/health_repo_impl.dart';

class HealthViewModel extends ChangeNotifier {
  final HealthRepo _repo = HealthRepoImpl();

  List<HealthModel> _items = [];
  bool _loading = false;
  String? _error;

  List<HealthModel> get items => _items;
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

  void _setItems(List<HealthModel> value) {
    _items = value;
    notifyListeners();
  }

  Future<void> fetchHealthItems(String userId) async {
    _setLoading(true);
    try {
      final data = await _repo.getHealthItems(userId);
      _setItems(data);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addHealthItem(HealthModel item, String userId) async {
    _setLoading(true);
    try {
      await _repo.addHealthItem(item, userId);
      await fetchHealthItems(userId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateHealthItem(HealthModel item, String userId) async {
    _setLoading(true);
    try {
      await _repo.updateHealthItem(item);
      await fetchHealthItems(userId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteHealthItem(String id, String userId) async {
    _setLoading(true);
    try {
      await _repo.deleteHealthItem(id);
      await fetchHealthItems(userId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
