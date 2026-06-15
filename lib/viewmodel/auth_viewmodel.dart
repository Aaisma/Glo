import 'package:flutter/material.dart';
import '../repo/user_repo.dart';
import '../repo/user_repo_impl.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepo _repo = UserRepoImpl();

  bool _loading = false;
  String? _error;
  String? _userId;

  bool get loading => _loading;
  String? get error => _error;
  String? get userId => _userId;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _setUserId(String? value) {
    _userId = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final id = await _repo.login(email, password);
      _setUserId(id);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      final id = await _repo.register(email, password);
      _setUserId(id);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repo.logout();
      _setUserId(null);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> forgetPassword(String email) async {
    _setLoading(true);
    try {
      await _repo.forgetPassword(email);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final id = await _repo.signInWithGoogle();
      _setUserId(id);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithFacebook() async {
    _setLoading(true);
    try {
      final id = await _repo.signInWithFacebook();
      _setUserId(id);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
