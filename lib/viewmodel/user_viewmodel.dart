import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/app_user.dart';

class UserViewModel extends ChangeNotifier {
  AppUser? user;
  bool isLoading = true;

  UserViewModel() {
    _init();
  }

  Future<void> _init() async {
    try {
      final auth = FirebaseAuth.instance;
      User? firebaseUser = auth.currentUser;

      // No user yet -> sign in anonymously so we always have a stable id
      firebaseUser ??= (await auth.signInAnonymously()).user;

      if (firebaseUser != null) {
        user = AppUser(id: firebaseUser.uid, email: firebaseUser.email);
      }
    } catch (e) {
      debugPrint('UserViewModel init error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}