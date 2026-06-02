import '../model/user_model.dart';
import '../repo/user_repo.dart';
import 'package:flutter/material.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepo _userRepo;

  UserViewModel({required UserRepo userRepo}) : _userRepo = userRepo;

  String? _error = "";
  String? get error => _error;

  bool _loading = false;
  bool get loading => _loading;

  UserModel? _user;
  UserModel? get user => _user;

  List<UserModel>? _allUsers;
  List<UserModel>? get allUsers => _allUsers;

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String? _userId;
  String? get userId => _userId;

  void setUserId(String id){
    _userId = id;
    notifyListeners();
  }

  Future<void> fetchCurrentUser() async {
    if (_userId == null) return;
    setLoading(true);
    setError(null);
    try {
      _user = await _userRepo.getUserByID(_userId!);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);
    try {
      final uid = await _userRepo.login(email, password);
      setUserId(uid);
      await fetchCurrentUser();
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> register(String email, String password) async {
    setLoading(true);
    setError(null);
    try {
      final uid = await _userRepo.register(email, password);
      setUserId(uid);
      await fetchCurrentUser();
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    setLoading(true);
    try {
      await _userRepo.logout();
      _userId = null;
      _user = null;
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<bool> forgetPassword(String email) async {
    setLoading(true);
    setError(null);
    try {
      await _userRepo.forgetPassword(email);
      return true;
    } on Exception catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> addUser(UserModel userModel) async {
    setLoading(true);
    try {
      await _userRepo.addUser(userModel);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteUser(String id) async {
    setLoading(true);
    try {
      await _userRepo.deleteUser(id);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> getAllUser() async {
    setLoading(true);
    setError(null);
    try {
      _allUsers = await _userRepo.getAllUser();
    } on Exception catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<UserModel?> getUserByID(String id) async {
    setLoading(true);
    try {
      final fetchedUser = await _userRepo.getUserByID(id);
      return fetchedUser;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> editProfile(UserModel userModel) async {
    setLoading(true);
    try {
      await _userRepo.editProfile(userModel);
      if (_user?.id == userModel.id) {
        _user = userModel;
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
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
    setLoading(true);
    try {
      await _userRepo.updateSurvey(
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
      await fetchCurrentUser(); // Refresh the user data
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}
