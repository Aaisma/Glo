import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';
import 'user_repo.dart';

class UserRepoImpl implements UserRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createDefaultProfile(User user) {
    return _firestore.collection("users").doc(user.uid).set({
      'id': user.uid,
      'email': user.email,
      'name': user.displayName ?? '',
      'surveyCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> addUser(UserModel userModel) {
    return _firestore
        .collection("users")
        .doc(userModel.id)
        .set(userModel.toMap());
  }

  @override
  Future<void> deleteUser(String id) {
    return _firestore.collection("users").doc(id).delete();
  }

  @override
  Future<void> editProfile(UserModel userModel) {
    return _firestore
        .collection("users")
        .doc(userModel.id)
        .update(userModel.toMap());
  }

  @override
  Future<List<UserModel>> getAllUser() async {
    final users = await _firestore.collection("users").get();
    return users.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  @override
  Future<UserModel?> getUserByID(String id) async {
    final doc = await _firestore.collection("users").doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserModel.fromMap(doc.data()!);
  }

  @override
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
  }) {
    return _firestore.collection("users").doc(userId).set({
      'id': userId,
      'email': email,
      'name': name ?? '',
      'ageGroup': ageGroup,
      'skinType': skinType,
      'goals': goals,
      'surveyCompleted': true,
      'actualAge': actualAge,
      'bmi': bmi,
      'waterGoal': waterGoal,
      'lastCycleDate': lastCycleDate?.toIso8601String(),
      'acneTypes': acneTypes,
      'usesMedication': usesMedication,
      'medicationType': medicationType,
      'medicationTime': medicationTime,
      'visitsDerma': visitsDerma,
      'lastDermaVisit': lastDermaVisit?.toIso8601String(),
    }, SetOptions(merge: true));
  }
}
