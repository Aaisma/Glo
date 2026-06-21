import '../model/user_model.dart';
import '../repo/user_repo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/onboarding_survey_data.dart';
import '../services_copy/onboarding_tracker_initializer.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepo _userRepo;

  UserViewModel({required UserRepo userRepo}) : _userRepo = userRepo;

  // Onboarding Survey Data & Signup Credentials
  OnboardingSurveyData _surveyData = OnboardingSurveyData();
  OnboardingSurveyData get surveyData => _surveyData;

  String _signupName = '';
  String _signupEmail = '';
  String _signupPassword = '';

  String get signupName => _signupName;
  String get signupEmail => _signupEmail;
  String get signupPassword => _signupPassword;

  void setSignupCredentials(String name, String email, String password) {
    _signupName = name;
    _signupEmail = email;
    _signupPassword = password;
    notifyListeners();
  }

  void updateSurveyData(OnboardingSurveyData data) {
    _surveyData = data;
    notifyListeners();
  }

  Future<void> saveOnboardingProgress(int currentStep) async {
    final box = Hive.box('onboarding_box');
    await box.put('current_step', currentStep);
    await box.put('survey_data', _surveyData.toMap());
    await box.put('signup_name', _signupName);
    await box.put('signup_email', _signupEmail);
  }

  Future<int> restoreOnboardingProgress() async {
    final box = Hive.box('onboarding_box');
    final step = box.get('current_step', defaultValue: 0) as int;
    final map = box.get('survey_data');
    if (map != null) {
      _surveyData = OnboardingSurveyData.fromMap(Map<String, dynamic>.from(map));
    }
    _signupName = box.get('signup_name', defaultValue: '') as String;
    _signupEmail = box.get('signup_email', defaultValue: '') as String;
    notifyListeners();
    return step;
  }

  Future<void> clearOnboardingProgress() async {
    final box = Hive.box('onboarding_box');
    await box.delete('current_step');
    await box.delete('survey_data');
    _surveyData = OnboardingSurveyData();
    _signupName = '';
    _signupEmail = '';
    _signupPassword = '';
    notifyListeners();
  }

  Future<void> finalizeOnboarding({
    required dynamic periodVM,
  }) async {
    setLoading(true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No authenticated user found.");
      }
      setUserId(user.uid);

      // 2. initializeTrackers()
      await OnboardingTrackerInitializer.initializeAllTrackers(
        userId: user.uid,
        surveyData: _surveyData,
      );

      // 3. saveSurveyAnswers() & markOnboardingComplete()
      await updateSurvey(
        userId: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        ageGroup: _surveyData.ageGroup ?? "Not specified",
        skinType: _surveyData.skinType ?? "Not specified",
        goals: _surveyData.goals,
        actualAge: _surveyData.actualAge,
        bmi: _surveyData.bmi,
        waterGoal: _surveyData.waterGoal,
        lastCycleDate: _surveyData.lastCycleDate,
        acneTypes: _surveyData.acneTypes,
        usesMedication: _surveyData.usesMedication,
        medicationType: _surveyData.medicationType,
        medicationTime: _surveyData.medicationTime,
        visitsDerma: _surveyData.visitsDerma,
        lastDermaVisit: _surveyData.lastDermaVisit,
      );

      // 4. Fetch cycle tracker logs to sync period data
      await periodVM.fetchLogs();

      // 5. Clean up local onboarding progress
      await clearOnboardingProgress();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }


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

  Future<void> createDefaultProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    setLoading(true);
    try {
      await _userRepo.createDefaultProfile(user);
      await fetchCurrentUser();
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

  Future<void> deleteAccount() async {
    setLoading(true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _userRepo.deleteUser(user.uid);
        await user.delete();
      }
      _user = null;
      _userId = null;
      await clearOnboardingProgress();
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
    required String email,
    String? name,
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
        email: email,
        name: name,
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
      // Immediately fetch latest profile, which has surveyCompleted = true
      await fetchCurrentUser();
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}
