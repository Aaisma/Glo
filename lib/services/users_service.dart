import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/user_profile_model.dart';

class UsersService {
  final _db = FirebaseFirestore.instance;

  Future<void> addUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUser(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String id) async {
    await _db.collection('users').doc(id).delete();
  }

  Future<void> addUserProfile(UserProfileModel profile) async {
    await _db.collection('user_profiles').doc(profile.id).set(profile.toMap());
  }

  Future<UserProfileModel?> getUserProfile(String id) async {
    final doc = await _db.collection('user_profiles').doc(id).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromMap(doc.data()!, doc.id);
  }
}
