import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpViewModel extends ChangeNotifier {
  final FirebaseAuth _auth;

  OtpViewModel({
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  bool loading = false;
  bool verified = false;

  String? userId;
  String? message;
  String? error;

  Future<bool> sendOtp(String phone) async {
    _clearStateForNewRequest();
    _setLoading(true);

    final completer = Completer<bool>();

    void completeOnce(bool value) {
      if (!completer.isCompleted) {
        completer.complete(value);
      }
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),

        verificationCompleted: (PhoneAuthCredential credential) async {
          final success = await _completeVerification(credential);
          completeOnce(success);
        },

        verificationFailed: (FirebaseAuthException e) {
          error = _mapFirebaseError(e);
          message = null;
          verified = false;
          _setLoading(false);
          completeOnce(false);
        },

        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          verified = false;
          error = null;
          message = "OTP sent successfully.";
          _setLoading(false);
          completeOnce(true);
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      error = _mapFirebaseError(e);
      message = null;
      verified = false;
      _setLoading(false);
      completeOnce(false);
    } catch (_) {
      error = "Failed to send OTP. Please try again.";
      message = null;
      verified = false;
      _setLoading(false);
      completeOnce(false);
    }

    return completer.future;
  }

  Future<bool> resendOtp(String phone) async {
    return sendOtp(phone);
  }

  Future<bool> verifyOtp(String otp) async {
    final code = otp.trim();

    message = null;
    error = null;

    if (code.length != 6) {
      error = "Please enter the 6-digit OTP.";
      notifyListeners();
      return false;
    }

    if (_verificationId == null || _verificationId!.isEmpty) {
      error = "OTP was not sent yet. Please resend code.";
      notifyListeners();
      return false;
    }

    _setLoading(true);

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: code,
    );

    return _completeVerification(credential);
  }

  Future<bool> _completeVerification(
      PhoneAuthCredential credential,
      ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        error = "Verification failed. User not found.";
        message = null;
        verified = false;
        _setLoading(false);
        return false;
      }

      userId = user.uid;
      verified = true;
      error = null;
      message = "OTP verified successfully.";
      _setLoading(false);

      return true;
    } on FirebaseAuthException catch (e) {
      error = _mapFirebaseError(e);
      message = null;
      verified = false;
      _setLoading(false);

      return false;
    } catch (_) {
      error = "Something went wrong. Please try again.";
      message = null;
      verified = false;
      _setLoading(false);

      return false;
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-phone-number":
        return "Invalid phone number.";
      case "invalid-verification-code":
        return "Invalid OTP code.";
      case "session-expired":
        return "OTP expired. Please resend code.";
      case "too-many-requests":
        return "Too many attempts. Please try again later.";
      case "network-request-failed":
        return "Network error. Please check your internet connection.";
      case "quota-exceeded":
        return "SMS quota exceeded. Please try again later.";
      default:
        return e.message ?? "Authentication failed. Please try again.";
    }
  }

  void _clearStateForNewRequest() {
    message = null;
    error = null;
    verified = false;
    userId = null;
  }

  void _setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}