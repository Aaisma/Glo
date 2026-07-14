import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepo {
  User? get currentUser;
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String email, String password);
  Future<User?> signInWithGoogle();
  Future<User?> signInWithFacebook();
  Future<void> signOut();
  Future<void> sendOtp(String phone);
  Future<bool> verifyOtp(String otp);
}
