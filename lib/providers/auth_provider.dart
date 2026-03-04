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

  void listenToUserChanges() {
    if (_firebaseUser != null) {
      _firestoreService.userStream(_firebaseUser!.uid).listen((user) {
        _userModel = user;
        notifyListeners();
      });
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
        notifyListeners();
      },
      onVerificationCompleted: (credential) async {
        await _signInWithCredential(credential);
      },
      onVerificationFailed: (e) {
        _error = e.message ?? 'Verification failed';
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
      _error = 'No verification ID found. Please resend OTP.';
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
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Invalid OTP';
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
        // Check if user exists in Firestore
        final existingUser =
            await _firestoreService.getUser(_firebaseUser!.uid);
        if (existingUser == null) {
          // Create new user
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
