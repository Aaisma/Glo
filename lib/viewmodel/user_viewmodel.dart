import '../model/user_model.dart';
import '../repo/user_repo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/onboarding_survey_data.dart';
import '../services/survey/onboarding_tracker_initializer.dart';

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

  Future<void> setSignupCredentials(String name, String email, String password) async {
    _signupName = name;
    _signupEmail = email;
    _signupPassword = password;
    notifyListeners();

    // SurveyPage.initState() unconditionally calls restoreOnboardingProgress()
    // on mount, which reads signup_name/signup_email straight back out of
    // Hive. Without persisting them here, that restore call immediately
    // overwrites what was just typed on the register screen with whatever
    // (or nothing) is left over in Hive from a previous attempt.
    final box = Hive.box('onboarding_box');
    await box.put('signup_name', _signupName);
    await box.put('signup_email', _signupEmail);
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
    await box.delete('signup_name');
    await box.delete('signup_email');
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
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (_signupEmail.isEmpty || _signupPassword.isEmpty) {
          throw Exception("No signup credentials found. Please try registering again.");
        }

        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _signupEmail,
          password: _signupPassword,
        );
        user = userCredential.user;

        if (user != null) {
          if (_signupName.isNotEmpty) {
            await user.updateDisplayName(_signupName);
          }
          await _userRepo.createDefaultProfile(user);
        }
      }

      if (user == null) {
        throw Exception("Failed to authenticate user.");
      }
      setUserId(user.uid);

      // 2. saveSurveyAnswers() & markOnboardingComplete() — this MUST run
      // before tracker initialization. If a tracker call fails and this ran
      // second, an already-created account would end up with
      // surveyCompleted still false, and AuthWrapper would loop the user
      // straight back into SurveyPage every launch with no way out except
      // re-running (and re-duplicating) tracker setup.
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

      // 3. initializeTrackers() — best-effort. Survey is already marked
      // complete above, so a failure here (isolated per-tracker inside
      // OnboardingTrackerInitializer too) can never strand the user in
      // SurveyPage or trigger a retry that duplicates entries.
      try {
        await OnboardingTrackerInitializer.initializeAllTrackers(
          userId: user.uid,
          surveyData: _surveyData,
        );
      } catch (e) {
        debugPrint('finalizeOnboarding: tracker initialization failed (non-fatal): $e');
      }

      // 4. Fetch cycle tracker logs to sync period data — also best-effort,
      // for the same reason.
      try {
        await periodVM.fetchLogs();
      } catch (e) {
        debugPrint('finalizeOnboarding: period log sync failed (non-fatal): $e');
      }

      // 5. Clean up local onboarding progress
      await clearOnboardingProgress();
    } catch (e, stackTrace) {
      // TEMP DEBUG: prints real exception type + trace to console.
      debugPrint('finalizeOnboarding real error: ${e.runtimeType} - $e');
      debugPrintStack(stackTrace: stackTrace);
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
  bool get isLoggedIn => _userId != null || FirebaseAuth.instance.currentUser != null;

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
      // Brand-new account (this only runs when no Firestore doc exists yet,
      // e.g. first Google/Facebook sign-in) — same reasoning as the manual
      // register path: any leftover local survey progress belongs to some
      // other, possibly abandoned attempt and must not resurface here.
      await clearOnboardingProgress();
      await _userRepo.createDefaultProfile(user);
      await fetchCurrentUser();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Resets locally-cached user state. Call this on logout (alongside
  /// FirebaseAuth.signOut()) so a different account signing in afterward
  /// never briefly sees the previous user's cached data before
  /// fetchCurrentUser() runs again.
  void clearUser() {
    _user = null;
    _userId = null;
    _error = null;
    notifyListeners();
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

  /// Flips `profileCompleted` to true for the current user without touching
  /// any other field, then refreshes `user` so AuthWrapper can route past
  /// GloProfileScreen on its next rebuild.
  Future<bool> completeProfile() async {
    final id = _userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (id == null) {
      setError('No logged-in user found');
      return false;
    }

    setLoading(true);
    setError(null);
    try {
      await _userRepo.markProfileCompleted(id);
      await fetchCurrentUser();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Syncs profile-screen edits (name, username, photo) into the canonical
  /// UserModel and, via UserRepo.editProfile, into any denormalized copies
  /// of the name/photo (discussion posts, community poll entries).
  ///
  /// ProfileViewModel owns the actual editing UI and its own Firestore
  /// write for its own fields (bio, Firebase Auth displayName, etc.) — this
  /// is the second half of every edit, called alongside it, so the two
  /// never drift apart. Only the fields passed in are changed; everything
  /// else on the user (survey answers, role, completion flags) is carried
  /// over from whatever is currently loaded so this can never clobber data
  /// ProfileViewModel doesn't know about.
  Future<UserModel?> updateProfileFields({
    String? name,
    String? username,
    String? imageUrl,
  }) async {
    final currentId = _userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (currentId == null) {
      setError('No logged-in user found');
      return null;
    }

    setLoading(true);
    setError(null);
    try {
      // Don't trust a possibly-stale cached _user (e.g. belonging to a
      // previous account, or never fetched this session) — refetch if it
      // doesn't match, so editProfile()'s full-document update can't wipe
      // fields this call isn't touching.
      final base = (_user != null && _user!.id == currentId)
          ? _user!
          : await _userRepo.getUserByID(currentId);

      if (base == null) {
        setError('No profile found to update');
        return null;
      }

      final updated = base.copyWith(
        name: name,
        username: username,
        imageUrl: imageUrl,
      );

      await _userRepo.editProfile(updated);
      _user = updated;
      notifyListeners();
      return updated;
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