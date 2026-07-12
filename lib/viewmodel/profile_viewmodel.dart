import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _profileSubscription;

  static const String defaultName = 'User';
  static const String defaultUsername = 'glo_user';
  static const String defaultBio =
      'Taking care of myself,\none day at a time.';

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  String _name = defaultName;
  String _username = defaultUsername;
  String _email = '';
  String _bio = defaultBio;
  String? _profileImagePath;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _auth.currentUser;

  String get name => _name;
  String get fullName => _name;
  String get username => _username;
  String get email => _email.isNotEmpty ? _email : currentUser?.email ?? '';
  String get bio => _bio;
  String? get profileImagePath => _profileImagePath;

  String get userName {
    if (_name.trim().isNotEmpty && _name != defaultName) {
      return _name;
    }

    final displayName = currentUser?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final userEmail = currentUser?.email?.trim();
    if (userEmail != null && userEmail.isNotEmpty) {
      return userEmail.split('@').first;
    }

    return defaultName;
  }

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = currentUser?.uid;

    if (uid == null || uid.trim().isEmpty) {
      return null;
    }

    return _firestore.collection('users').doc(uid);
  }

  Future<void> loadProfile() async {
    startProfileListener();
  }

  void startProfileListener() {
    final user = currentUser;

    if (user == null) {
      _resetProfile();
      _errorMessage = 'No logged-in user found';
      notifyListeners();
      return;
    }

    final docRef = _userDoc;

    if (docRef == null) {
      _resetProfile();
      _errorMessage = 'No profile document found';
      notifyListeners();
      return;
    }

    _profileSubscription?.cancel();

    _setLoading(true);
    _errorMessage = null;

    _profileSubscription = docRef.snapshots().listen(
          (snapshot) {
        _applyProfileSnapshot(user, snapshot);

        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> refreshProfile() async {
    final user = currentUser;
    final docRef = _userDoc;

    if (user == null || docRef == null) {
      _resetProfile();
      _errorMessage = 'No logged-in user found';
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      final snapshot = await docRef.get();
      _applyProfileSnapshot(user, snapshot);
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveProfile({
    required String name,
    required String bio,
    String? username,
  }) async {
    final cleanName = name.trim();
    final cleanBio = bio.trim().isEmpty ? defaultBio : bio.trim();
    final cleanUsername = username?.trim() ?? _username;

    if (cleanName.isEmpty) {
      return _fail('Name cannot be empty');
    }

    if (cleanUsername.isEmpty) {
      return _fail('Username cannot be empty');
    }

    return _run(
      () async {
        final user = currentUser;
        final docRef = _userDoc;

        if (user == null || docRef == null) {
          return _fail('No logged-in user found');
        }

        final authEmail = user.email?.trim() ?? '';

        await docRef.set(
          {
            'uid': user.uid,
            'fullName': cleanName,
            'name': cleanName,
            'username': cleanUsername,
            'email': authEmail,
            'bio': cleanBio,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        await user.updateDisplayName(cleanName);
        await user.reload();

        _name = cleanName;
        _username = cleanUsername;
        _email = authEmail;
        _bio = cleanBio;

        notifyListeners();
        return true;
      },
      fallbackError: 'Failed to update profile',
    );
  }

  Future<bool> updateProfileName(String name) async {
    return saveProfile(
      name: name,
      bio: _bio,
    );
  }

  Future<bool> updateProfileImage(String imagePath) async {
    final cleanPath = imagePath.trim();

    if (cleanPath.isEmpty) {
      return _fail('Invalid image selected');
    }

    return _run(
          () async {
        final user = currentUser;
        final docRef = _userDoc;

        if (user == null || docRef == null) {
          return _fail('No logged-in user found');
        }

        await docRef.set(
          {
            'profileImagePath': cleanPath,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        _profileImagePath = cleanPath;

        notifyListeners();
        return true;
      },
      fallbackError: 'Failed to update profile picture',
    );
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

    return _run(
          () async {
        final user = currentUser;
        final userEmail = user?.email;

        if (user == null || userEmail == null || userEmail.trim().isEmpty) {
          return _fail('No email/password user found');
        }

        final credential = EmailAuthProvider.credential(
          email: userEmail,
          password: current,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(next);

        return true;
      },
      fallbackError: 'Failed to change password',
    );
  }

  Future<bool> logout() {
    return _run(
          () async {
        await _profileSubscription?.cancel();
        _profileSubscription = null;

        _resetProfile();

        await _auth.signOut();

        return true;
      },
      fallbackError: 'Logout failed',
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _applyProfileSnapshot(
      User user,
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      ) {
    final data = snapshot.data();

    final authName = _authName(user);
    final authEmail = user.email?.trim() ?? '';
    final authUsername = _usernameFromEmail(authEmail);
    final authPhotoUrl = user.photoURL?.trim();

    if (data == null) {
      _name = authName;
      _username = authUsername;
      _email = authEmail;
      _bio = defaultBio;
      _profileImagePath =
      authPhotoUrl != null && authPhotoUrl.isNotEmpty ? authPhotoUrl : null;
      return;
    }

    _name = _firstString(data, [
      'fullName',
      'name',
      'displayName',
    ]) ??
        authName;

    _username = _firstString(data, [
      'username',
      'userName',
    ]) ??
        authUsername;

    _email = _firstString(data, ['email']) ?? authEmail;

    _bio = _firstString(data, ['bio']) ?? defaultBio;

    _profileImagePath = _firstString(data, [
      'profileImagePath',
      'profileImageUrl',
      'photoUrl',
      'photoURL',
      'imageUrl',
      'avatarUrl',
    ]) ??
        authPhotoUrl;
  }

  String _authName(User user) {
    final displayName = user.displayName?.trim();
    final authEmail = user.email?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    if (authEmail != null && authEmail.isNotEmpty) {
      return authEmail.split('@').first;
    }

    return defaultName;
  }

  String _usernameFromEmail(String email) {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return defaultUsername;
    }

    final username = cleanEmail.split('@').first.trim();

    return username.isEmpty ? defaultUsername : username;
  }

  String? _firstString(
      Map<String, dynamic> data,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = data[key];

      if (value == null) continue;

      final text = value.toString().trim();

      if (text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  Future<bool> _run(
      Future<bool> Function() action, {
        required String fallbackError,
      }) async {
    try {
      _setSaving(true);
      _errorMessage = null;

      return await action();
    } on FirebaseAuthException catch (e) {
      return _fail(_firebaseErrorMessage(e, fallbackError));
    } on FirebaseException catch (e) {
      return _fail(e.message ?? fallbackError);
    } catch (e) {
      return _fail('$fallbackError: $e');
    } finally {
      _setSaving(false);
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

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _resetProfile() {
    _name = defaultName;
    _username = defaultUsername;
    _email = '';
    _bio = defaultBio;
    _profileImagePath = null;
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
      case 'network-request-failed':
        return 'Network error. Please check your internet connection';
      default:
        return e.message ?? fallbackError;
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}