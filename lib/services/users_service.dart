import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glo/model/user_profile_model.dart';

class UsersService {
  final _db = FirebaseFirestore.instance;

  /// Add a new user profile
  Future<void> addUser(UserProfile user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  /// Fetch a single user profile by ID (real-time stream)
  Stream<UserProfile> fetchUser(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => UserProfile.fromMap(doc.data()!, doc.id));
  }

  /// Update an existing user profile
  Future<void> updateUser(UserProfile user) async {
    await _db.collection('users').doc(user.id).update(user.toMap());
  }

  /// Delete a user profile by ID
  Future<void> deleteUser(String id) async {
    await _db.collection('users').doc(id).delete();
  }
}
