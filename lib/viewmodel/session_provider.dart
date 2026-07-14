import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionProvider extends ChangeNotifier {
  String? _userId;
  String? get userId => _userId;
  bool get isLoggedIn => _userId != null;

  StreamSubscription<User?>? _authSubscription;

  SessionProvider() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (_userId != user?.uid) {
        _userId = user?.uid;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
