import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../repo/auth_repo.dart';
import '../repo/user_repo.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepo _authRepo;
  final UserRepo _userRepo;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _loading = false;
  String? _error;
  String? get error => _error;
  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

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
      final user = await _authRepo.signInWithEmail(email, password);
      _user = user;
      notifyListeners();
      if (context.mounted) {
        // await checkUserProfile(context, _user!.uid);
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
      final user = await _authRepo.signUpWithEmail(email, password);
      _user = user;
      notifyListeners();
      return _user;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Email Sign Up
  Future<User?> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setError(null);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Email Sign In
  Future<User?> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setError(null);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In (Fixed for Google Sign-In v7+)
  Future<User?> signInWithGoogle() async {
    _setLoading(true);
    try {
      final user = await _authRepo.signInWithGoogle();
      _user = user;
      notifyListeners();
      return user;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Facebook Sign In
  Future<User?> signInWithFacebook() async {
    _setLoading(true);
    try {
      final user = await _authRepo.signInWithFacebook();
      _user = user;
      notifyListeners();
      return user;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out (Fixed for Google Sign-In v7+)
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await Future.wait([
        _auth.signOut(),
        GoogleSignIn().signOut(),
        FacebookAuth.instance.logOut(),
      ]);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}