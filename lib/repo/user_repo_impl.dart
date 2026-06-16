import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
=======
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
>>>>>>> pranisha_branch
import '../model/user_model.dart';
import 'user_repo.dart';

class UserRepoImpl implements UserRepo {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  @override
  Future<void> addUser(UserModel userModel) {
<<<<<<< HEAD
    return firestore.collection("users").doc(userModel.id).set(userModel.toMap());
=======
    return firestore
        .collection("users")
        .doc(userModel.id)
        .set(userModel.toMap());
>>>>>>> pranisha_branch
  }

  @override
  Future<void> deleteUser(String id) {
    return firestore.collection("users").doc(id).delete();
  }

  @override
  Future<void> editProfile(UserModel userModel) {
<<<<<<< HEAD
    return firestore.collection("users").doc(userModel.id).update(userModel.toMap());
=======
    return firestore
        .collection("users")
        .doc(userModel.id)
        .update(userModel.toMap());
>>>>>>> pranisha_branch
  }

  @override
  Future<void> forgetPassword(String email) {
    return auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<List<UserModel>> getAllUser() async {
    final users = await firestore.collection("users").get();
<<<<<<< HEAD
    return users.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
=======

    List<UserModel> data = [];
    for (int i = 0; i < users.docs.length; i++) {
      data.add(UserModel.fromMap(users.docs[i].data()));
    }
    return data;
>>>>>>> pranisha_branch
  }

  @override
  Future<UserModel> getUserByID(String id) async {
<<<<<<< HEAD
    final doc = await firestore.collection("users").doc(id).get();
    final data = doc.data();
    if (data == null) throw Exception("Unable to fetch data.");
    return UserModel.fromMap(data, doc.id);
=======
    final users = await firestore.collection("users").doc(id).get();
    final data = users.data();

    if (data == null) {
      throw Exception("Unable to fetch data.");
    }
    return UserModel.fromMap(data);
>>>>>>> pranisha_branch
  }

  @override
  Future<String> login(String email, String password) async {
<<<<<<< HEAD
    final user = await auth.signInWithEmailAndPassword(email: email, password: password);
    final userId = user.user?.uid;
    if (userId == null) throw Exception("Login failed");
=======
    final user = await auth.signInWithEmailAndPassword(
        email: email, password: password);
    final userId = user.user?.uid;

    if (userId == null) {
      throw Exception("login failed");
    }
>>>>>>> pranisha_branch
    return userId;
  }

  @override
  Future<void> logout() {
    return auth.signOut();
  }

  @override
  Future<String> register(String email, String password) async {
<<<<<<< HEAD
    final userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    final userId = userCredential.user?.uid;
    if (userId == null) throw Exception("Registration failed");
=======
    final userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final userId = userCredential.user?.uid;

    if (userId == null) {
      throw Exception("Registration failed");
    }
>>>>>>> pranisha_branch

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
<<<<<<< HEAD
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

=======
    // In version 7.2.0+, use GoogleSignIn.instance and authenticate()
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

    // authentication is now a synchronous getter
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: null, // accessToken is optional if idToken is provided
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
    await auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user == null) throw Exception("Google sign in failed");

    // Check if user exists in Firestore, if not create
>>>>>>> pranisha_branch
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
<<<<<<< HEAD
      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);

      final UserCredential userCredential = await auth.signInWithCredential(credential);
      final User? user = userCredential.user;
=======
      final OAuthCredential credential =
      FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final UserCredential userCredential =
      await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

>>>>>>> pranisha_branch
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
