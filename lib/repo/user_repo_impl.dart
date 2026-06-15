import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../model/user_model.dart';
import 'user_repo.dart';

class UserRepoImpl implements UserRepo {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  @override
  Future<void> addUser(UserModel userModel) {
    return firestore.collection("users").doc(userModel.id).set(userModel.toMap());
  }

  @override
  Future<void> deleteUser(String id) {
    return firestore.collection("users").doc(id).delete();
  }

  @override
  Future<void> editProfile(UserModel userModel) {
    return firestore.collection("users").doc(userModel.id).update(userModel.toMap());
  }

  @override
  Future<void> forgetPassword(String email) {
    return auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<List<UserModel>> getAllUser() async {
    final users = await firestore.collection("users").get();
    return users.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<UserModel> getUserByID(String id) async {
    final doc = await firestore.collection("users").doc(id).get();
    final data = doc.data();
    if (data == null) throw Exception("Unable to fetch data.");
    return UserModel.fromMap(data, doc.id);
  }

  @override
  Future<String> login(String email, String password) async {
    final user = await auth.signInWithEmailAndPassword(email: email, password: password);
    final userId = user.user?.uid;
    if (userId == null) throw Exception("Login failed");
    return userId;
  }

  @override
  Future<void> logout() {
    return auth.signOut();
  }

  @override
  Future<String> register(String email, String password) async {
    final userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    final userId = userCredential.user?.uid;
    if (userId == null) throw Exception("Registration failed");

    await firestore.collection("users").doc(userId).set({
      'id': userId,
      'email': email,
      'name': '',
      'surveyCompleted': false,
    });

    return userId;
  }

  @override
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception("Google sign in cancelled");

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await auth.signInWithCredential(credential);
    final User? user = userCredential.user;
    if (user == null) throw Exception("Google sign in failed");

    final doc = await firestore.collection("users").doc(user.uid).get();
    if (!doc.exists) {
      await firestore.collection("users").doc(user.uid).set({
        'id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'surveyCompleted': false,
      });
    }

    return user.uid;
  }

  @override
  Future<String> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);

      final UserCredential userCredential = await auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) throw Exception("Facebook sign in failed");

      final doc = await firestore.collection("users").doc(user.uid).get();
      if (!doc.exists) {
        await firestore.collection("users").doc(user.uid).set({
          'id': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? '',
          'surveyCompleted': false,
        });
      }
      return user.uid;
    } else {
      throw Exception("Facebook sign in failed: ${result.message}");
    }
  }

  @override
  Future<void> updateSurvey({
    required String userId,
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
    return firestore.collection("users").doc(userId).update({
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
    });
  }
}
