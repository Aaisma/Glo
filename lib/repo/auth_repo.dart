import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepo {
Future<void> sendOtp(String phone);
Future<bool> verifyOtp(String otp);
}
