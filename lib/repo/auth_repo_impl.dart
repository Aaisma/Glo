import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    const String googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '714010295460-brtm8b47nffm381uje37pkkbr7bvuenj.apps.googleusercontent.com');
    final gsi.GoogleSignIn googleSignIn = gsi.GoogleSignIn(
      clientId: (kIsWeb || Platform.isIOS) ? googleClientId : null,
      serverClientId: googleClientId,
    );
    final gsi.GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) throw Exception("Google sign in cancelled");

    final gsi.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<UserCredential> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
      return await _auth.signInWithCredential(credential);
    } else {
      throw Exception("Facebook sign in failed: ${result.message}");
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await gsi.GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }

  @override
  Future<void> forgetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  User? get currentUser => _auth.currentUser;
}
