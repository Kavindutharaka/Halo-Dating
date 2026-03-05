import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:halo/models/user_model.dart';
import 'package:halo/services/auth_service.dart';
import 'package:halo/services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  String? _verificationId;
  int? _resendToken;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isProfileComplete => _userModel?.isProfileComplete ?? false;

  AuthProvider() {
    _authService.authStateChanges.listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserModel(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel(String uid) async {
    _userModel = await _firestoreService.getUser(uid);
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_firebaseUser != null) {
      await _loadUserModel(_firebaseUser!.uid);
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      resendToken: _resendToken,
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onVerificationCompleted: (credential) async {
        // Auto-verification (some Android devices do this automatically)
        await _signInWithCredential(credential);
      },
      onVerificationFailed: (e) {
        switch (e.code) {
          case 'invalid-phone-number':
            _error = 'Invalid phone number format.';
            break;
          case 'too-many-requests':
            _error = 'Too many attempts. Please wait and try again.';
            break;
          case 'operation-not-allowed':
            _error = 'Phone sign-in is not enabled. Contact support.';
            break;
          default:
            _error = e.message ?? 'Failed to send OTP. Try again.';
        }
        _isLoading = false;
        notifyListeners();
      },
      onCodeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) {
      _error = 'Session expired. Please request a new OTP.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credential = _authService.createCredential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signInWithCredential(credential);
      return _firebaseUser != null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-verification-code':
          _error = 'Incorrect OTP. Please check and try again.';
          break;
        case 'session-expired':
          _error = 'OTP expired. Please request a new one.';
          break;
        default:
          _error = e.message ?? 'Verification failed.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final result = await _authService.signInWithCredential(credential);
      _firebaseUser = result.user;

      if (_firebaseUser != null) {
        final existingUser =
            await _firestoreService.getUser(_firebaseUser!.uid);
        if (existingUser == null) {
          final newUser = UserModel(
            uid: _firebaseUser!.uid,
            phoneNumber: _firebaseUser!.phoneNumber ?? '',
          );
          await _firestoreService.createUser(newUser);
          _userModel = newUser;
        } else {
          _userModel = existingUser;
        }
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Sign in failed';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateUser(updatedUser);
      _userModel = updatedUser;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _firebaseUser = null;
    _userModel = null;
    _verificationId = null;
    _resendToken = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
