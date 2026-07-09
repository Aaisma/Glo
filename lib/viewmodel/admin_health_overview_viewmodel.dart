// lib/viewmodel/admin_health_overview_viewmodel.dart
import 'package:flutter/material.dart';
import '../model/health_overview_model.dart';
import '../repo/admin_health_overview_repo.dart';

class AdminHealthOverviewViewModel extends ChangeNotifier {
  final AdminHealthOverviewRepo repo;

  AdminHealthOverviewViewModel(this.repo);

  HealthOverviewData? _overview;
  bool _loading = false;

  HealthOverviewData? get overview => _overview;
  bool get loading => _loading;

  Future<void> loadOverview() async {
    _loading = true;
    notifyListeners();

    _overview = await repo.fetchOverview();

    _loading = false;
    notifyListeners();
  }
}
