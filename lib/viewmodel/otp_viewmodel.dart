import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpViewModel extends ChangeNotifier {
  final FirebaseAuth _auth;

  OtpViewModel({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;
  bool _loading = false;
  String? _error;
  String? _message;
  bool _verified = false;

  bool get loading => _loading;
  String? get error => _error;
  String? get message => _message;
  bool get verified => _verified;
  User? get currentUser => _auth.currentUser;

  Future<bool> sendOtp(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      _setError("Phone number is required.");
      return false;
    }

    final completer = Completer<bool>();

    _setLoading(true);
    _error = null;
    _message = null;
    _verified = false;
    notifyListeners();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);

            _verified = true;
            _message = "Phone verified automatically.";
            _error = null;
            _setLoading(false);

            if (!completer.isCompleted) {
              completer.complete(true);
            }
          } catch (e) {
            _setError("Auto verification failed.");
            if (!completer.isCompleted) {
              completer.complete(false);
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError(_getFirebaseErrorMessage(e));

          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _message = "OTP sent successfully.";
          _error = null;
          _setLoading(false);

          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _setError(e.toString());

      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  Future<bool> verifyOtp(String otp) async {
    if (otp.trim().length != 6) {
      _setError("Please enter the 6-digit OTP.");
      return false;
    }

    if (_verificationId == null) {
      _setError("OTP not sent yet. Please resend code.");
      return false;
    }

    _setLoading(true);
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp.trim(),
      );

      await _auth.signInWithCredential(credential);

      _verified = true;
      _message = "OTP verified successfully.";
      _error = null;
      _setLoading(false);

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFirebaseErrorMessage(e));
      return false;
    } catch (e) {
      _setError("Something went wrong.");
      return false;
    }
  }

  Future<bool> resendOtp(String phoneNumber) async {
    _verificationId = null;
    _message = null;
    _error = null;
    _verified = false;
    notifyListeners();

    return sendOtp(phoneNumber);
  }

  void clearMessage() {
    _message = null;
    _error = null;
    notifyListeners();
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    if (e.code == "invalid-phone-number") {
      return "Invalid phone number.";
    }

    if (e.code == "invalid-verification-code") {
      return "Invalid OTP code.";
    }

    if (e.code == "session-expired") {
      return "OTP expired. Please resend code.";
    }

    if (e.message != null && e.message!.trim().isNotEmpty) {
      return e.message!;
    }

    return "OTP verification failed.";
  }

  void _setError(String value) {
    _error = value;
    _message = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}