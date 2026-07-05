import 'dart:async';

import 'package:flutter/material.dart';

import '../model/health_model.dart';
import '../repo/health_repo.dart';
import '../repo/health_repo_impl.dart';

class HealthViewModel extends ChangeNotifier {
  HealthViewModel({
    HealthRepo? repo,
  }) : _repo = repo ?? HealthRepoImpl();

  final HealthRepo _repo;

  List<HealthModel> _items = [];
  bool _loading = false;
  String? _error;

  StreamSubscription<List<HealthModel>>? _healthSubscription;

  List<HealthModel> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchHealthItems(String userId) async {
    try {
      _validateUserId(userId);
      _setLoading(true);
      _error = null;

      _items = await _repo.getHealthItems(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Stream<List<HealthModel>> fetchHealthItemsStream(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.error(Exception("User ID is required."));
    }

    return _repo.getHealthItemsStream(userId);
  }

  void listenToHealthItems(String userId) {
    _healthSubscription?.cancel();

    if (userId.trim().isEmpty) {
      _error = "User ID is required.";
      _loading = false;
      notifyListeners();
      return;
    }

    _setLoading(true);

    _healthSubscription = _repo.getHealthItemsStream(userId).listen(
          (items) {
        _items = items;
        _error = null;
        _loading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addHealthItem(
      HealthModel item,
      String userId,
      ) async {
    try {
      _validateUserId(userId);
      _setLoading(true);
      _error = null;

      item.userId = userId;

      await _repo.addHealthItem(item, userId);
      await fetchHealthItems(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateHealthItem(
      HealthModel item,
      String userId,
      ) async {
    try {
      _validateUserId(userId);
      _setLoading(true);
      _error = null;

      item.userId = userId;

      await _repo.updateHealthItem(item, userId);
      await fetchHealthItems(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteHealthItem(
      String id,
      String userId,
      ) async {
    try {
      _validateUserId(userId);
      _setLoading(true);
      _error = null;

      await _repo.deleteHealthItem(id);
      await fetchHealthItems(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Stream<int> getHealthItemCountStream(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.error(Exception("User ID is required."));
    }

    return _repo.getHealthItemCountStream(userId);
  }

  Stream<int> getAllHealthItemCountStream() {
    return _repo.getAllHealthItemCountStream();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw Exception("User ID is required.");
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _healthSubscription?.cancel();
    super.dispose();
  }
}