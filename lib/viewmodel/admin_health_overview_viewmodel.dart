// lib/viewmodel/admin_health_overview_viewmodel.dart

import 'package:flutter/material.dart';

import '../model/health_overview_model.dart';
import '../repo/admin_health_overview_repo.dart';

class AdminHealthOverviewViewModel extends ChangeNotifier {
  final AdminHealthOverviewRepo repo;

  AdminHealthOverviewViewModel(this.repo);

  HealthOverviewData? _overview;
  bool _loading = false;
  String? _errorMessage;

  HealthOverviewData? get overview => _overview;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOverview() async {
    if (_loading) return;

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _overview = await repo.fetchOverview();
    } catch (error) {
      _errorMessage = 'Unable to load health overview data.';
      debugPrint('Health overview error: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshOverview() async {
    await loadOverview();
  }
}