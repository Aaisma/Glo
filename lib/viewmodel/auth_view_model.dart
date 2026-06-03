import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repo/auth_repo.dart';
import '../repo/user_repo.dart';
import '../model/user_model.dart';
import 'package:provider/provider.dart';
import 'user_view_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepo _authRepo;
  final UserRepo _userRepo;
  
  User? _user;
  bool _loading = false;

  AuthViewModel({required AuthRepo authRepo, required UserRepo userRepo}) 
      : _authRepo = authRepo, 
        _userRepo = userRepo {
    _user = _authRepo.currentUser;
  }

  User? get user => _user;
  bool get loading => _loading;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context, String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _authRepo.signInWithEmail(email, password);
      _user = credential.user;
      notifyListeners();
      if (context.mounted) {
        await checkUserProfile(context, _user!.uid);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> signUp(String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _authRepo.signUpWithEmail(email, password);
      _user = credential.user;
      notifyListeners();
      return _user;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      final credential = await _authRepo.signInWithGoogle();
      _user = credential.user;
      notifyListeners();
      if (context.mounted) {
        await checkUserProfile(context, _user!.uid);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    _setLoading(true);
    try {
      final credential = await _authRepo.signInWithFacebook();
      _user = credential.user;
      notifyListeners();
      if (context.mounted) {
        await checkUserProfile(context, _user!.uid);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkUserProfile(BuildContext context, String uid) async {
    try {
      final userProfile = await _userRepo.getUserByID(uid);
      if (context.mounted) {
        final userVM = context.read<UserViewModel>();
        userVM.setUserId(uid);
        if (userProfile != null) {
          await userVM.fetchCurrentUser();
        }

        if (context.mounted) {
          if (userProfile == null) {
            Navigator.pushReplacementNamed(context, '/survey');
          } else if (userProfile.surveyCompleted == true) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard'); // surveyCompleted == false (skip case)
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/survey');
      }
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    _user = null;
    notifyListeners();
  }
}
