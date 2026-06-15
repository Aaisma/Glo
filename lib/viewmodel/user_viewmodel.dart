import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../repo/user_repo.dart';
import '../repo/user_repo_impl.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepo _repo = UserRepoImpl();

  bool _loading = false;
  String? _error;
  List<UserModel> _users = [];
  UserModel? _currentUser;

  bool get loading => _loading;
  String? get error => _error;
  List<UserModel> get users => _users;
  UserModel? get currentUser => _currentUser;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _setUsers(List<UserModel> value) {
    _users = value;
    notifyListeners();
  }

  void _setCurrentUser(UserModel? value) {
    _currentUser = value;
    notifyListeners();
  }

  Future<void> fetchAllUsers() async {
    _setLoading(true);
    try {
      final data = await _repo.getAllUser();
      _setUsers(data);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUserById(String id) async {
    _setLoading(true);
    try {
      final user = await _repo.getUserByID(id);
      _setCurrentUser(user);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addUser(UserModel user) async {
    _setLoading(true);
    try {
      await _repo.addUser(user);
      await fetchAllUsers();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> editProfile(UserModel user) async {
    _setLoading(true);
    try {
      await _repo.editProfile(user);
      await fetchUserById(user.id);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String id) async {
    _setLoading(true);
    try {
      await _repo.deleteUser(id);
      await fetchAllUsers();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSurvey({
    required String userId,
    required String ageGroup,
    required String skinType,
    required List<String> goals,
    int? actualAge,
    double? bmi,
    double? waterGoal,
    DateTime? lastCycleDate,
    List<String>? acneTypes,
    bool? usesMedication,
    String? medicationType,
    String? medicationTime,
    bool? visitsDerma,
    DateTime? lastDermaVisit,
  }) async {
    _setLoading(true);
    try {
      await _repo.updateSurvey(
        userId: userId,
        ageGroup: ageGroup,
        skinType: skinType,
        goals: goals,
        actualAge: actualAge,
        bmi: bmi,
        waterGoal: waterGoal,
        lastCycleDate: lastCycleDate,
        acneTypes: acneTypes,
        usesMedication: usesMedication,
        medicationType: medicationType,
        medicationTime: medicationTime,
        visitsDerma: visitsDerma,
        lastDermaVisit: lastDermaVisit,
      );
      await fetchUserById(userId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
