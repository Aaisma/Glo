import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';
import 'user_repo.dart';

class UserRepoImpl implements UserRepo {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  @override
  Future<void> addUser(UserModel userModel) {
    return firestore
        .collection("users")
        .doc(userModel.id)
        .set(userModel.toMap());
  }

  @override
  Future<void> createDefaultProfile(User user) async {
    final docRef = firestore.collection("users").doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      final newUser = UserModel(
        id: user.uid,
        email: user.email,
        name: user.displayName ?? '',
        role: 'user',
        surveyCompleted: false,
        profileCompleted: false,
      );
      await docRef.set(newUser.toMap());
    }
  }

  @override
  Future<void> deleteUser(String id) {
    return firestore.collection("users").doc(id).delete();
  }

  @override
  Future<void> editProfile(UserModel userModel) async {
    final batch = firestore.batch();
    final userRef = firestore.collection("users").doc(userModel.id);
    batch.update(userRef, userModel.toMap());

    try {
      final discQuery = await firestore.collection('discussions').where('userId', isEqualTo: userModel.id).get();
      for (var doc in discQuery.docs) {
        batch.update(doc.reference, {
          'username': userModel.name,
          'profileImageUrl': userModel.imageUrl,
        });
      }

      final pollQuery = await firestore.collection('community_polls').where('userId', isEqualTo: userModel.id).get();
      for (var doc in pollQuery.docs) {
        batch.update(doc.reference, {
          'username': userModel.name,
          'profileImageUrl': userModel.imageUrl,
        });
      }
    } catch (e) {
      // Ignore index errors if they occur during profile update before indexes are ready
    }

    await batch.commit();
  }

  @override
  Future<void> markProfileCompleted(String userId) {
    // Merge-only write: touches nothing but this one flag, so it can never
    // clobber fields owned by ProfileViewModel (bio, username, profileImagePath)
    // or survey data written by updateSurvey().
    return firestore.collection("users").doc(userId).set(
      {'profileCompleted': true},
      SetOptions(merge: true),
    );
  }

  @override
  Future<List<UserModel>> getAllUser() async {
    final users = await firestore.collection("users").get();
    return users.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<UserModel?> getUserByID(String id) async {
    final doc = await firestore.collection("users").doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserModel.fromMap(doc.data()!, doc.id);
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
    return firestore.collection("users").doc(userId).set({
      'id': userId,
      'email': email,
      'name': name == null || name.isEmpty ? 'N/A' : name,
      'ageGroup': ageGroup.isEmpty || ageGroup == "Not specified" ? 'N/A' : ageGroup,
      'skinType': skinType.isEmpty || skinType == "Not specified" ? 'N/A' : skinType,
      'goals': goals.isEmpty ? ['N/A'] : goals,
      'surveyCompleted': true,
      'actualAge': actualAge ?? 'N/A',
      'bmi': bmi ?? 'N/A',
      'waterGoal': waterGoal ?? 'N/A',
      'lastCycleDate': lastCycleDate?.toIso8601String() ?? 'N/A',
      'acneTypes': acneTypes == null || acneTypes.isEmpty ? ['N/A'] : acneTypes,
      'usesMedication': usesMedication ?? 'N/A',
      'medicationType': medicationType == null || medicationType.isEmpty || medicationType == "Not specified" ? 'N/A' : medicationType,
      'medicationTime': medicationTime == null || medicationTime.isEmpty || medicationTime == "Not specified" ? 'N/A' : medicationTime,
      'visitsDerma': visitsDerma ?? 'N/A',
      'lastDermaVisit': lastDermaVisit?.toIso8601String() ?? 'N/A',
    }, SetOptions(merge: true));
  }
}