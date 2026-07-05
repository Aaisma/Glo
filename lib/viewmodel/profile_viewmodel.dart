
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _auth.currentUser;
  String? get email => currentUser?.email;

  String get userName {
    final displayName = currentUser?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final userEmail = currentUser?.email?.trim();
    if (userEmail != null && userEmail.isNotEmpty) {
      return userEmail.split('@').first;
    }

    return 'User';
  }

  Future<bool> updateProfileName(String name) async {
    final newName = name.trim();

    if (newName.isEmpty) {
      return _fail('Name cannot be empty');
    }

    return _run(() async {
      final user = currentUser;

      if (user == null) {
        return _fail('No logged-in user found');
      }

      await user.updateDisplayName(newName);
      await user.reload();
      notifyListeners();

      return true;
    }, fallbackError: 'Failed to update profile');
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final current = currentPassword.trim();
    final next = newPassword.trim();
    final confirm = confirmPassword.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      return _fail('Please fill all password fields');
    }

    if (next.length < 6) {
      return _fail('Password must be at least 6 characters');
    }

    if (next != confirm) {
      return _fail('New passwords do not match');
    }

    return _run(() async {
      final user = currentUser;
      final userEmail = user?.email;

      if (user == null || userEmail == null) {
        return _fail('No logged-in user found');
      }

      final credential = EmailAuthProvider.credential(
        email: userEmail,
        password: current,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(next);

      return true;
    }, fallbackError: 'Failed to change password');
  }

  Future<bool> logout() {
    return _run(() async {
      await _auth.signOut();
      return true;
    }, fallbackError: 'Logout failed');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(
      Future<bool> Function() action, {
        required String fallbackError,
      }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      return await action();
    } on FirebaseAuthException catch (e) {
      return _fail(_firebaseErrorMessage(e, fallbackError));
    } catch (e) {
      return _fail('$fallbackError: $e');
    } finally {
      _setLoading(false);
    }
  }

  bool _fail(String message) {
    _errorMessage = message;
    notifyListeners();
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _firebaseErrorMessage(
      FirebaseAuthException e,
      String fallbackError,
      ) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Current password is incorrect';
      case 'weak-password':
        return 'New password is too weak';
      case 'requires-recent-login':
        return 'Please login again before changing password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'user-not-found':
        return 'No user account found';
      default:
        return e.message ?? fallbackError;
    }
  }
}