import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint('🔵 [AuthProvider] Initializing, setting up auth state listener');
    _authService.authStateChanges.listen((user) async {
      debugPrint('🔵 [AuthProvider] Auth state changed: user=${user?.uid ?? 'null'}');
      _firebaseUser = user;
      if (user != null) {
        debugPrint('🔵 [AuthProvider] User logged in, loading Firestore model...');
        await _loadUserModel(user.uid);
      } else {
        debugPrint('🔵 [AuthProvider] User logged out');
        _userModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserModel(String uid) async {
    debugPrint('🔵 [AuthProvider] _loadUserModel called for uid=$uid');
    try {
      _userModel = await _firestoreService.getUser(uid);
      debugPrint('🟢 [AuthProvider] _loadUserModel success: userModel=${_userModel == null ? 'null (no document)' : 'loaded'}');

      // Document missing — create it now (can happen if previous sign-in failed mid-way)
      if (_userModel == null && _firebaseUser != null) {
        debugPrint('🟡 [AuthProvider] Document missing for existing auth user — creating now');
        final newUser = UserModel(
          uid: _firebaseUser!.uid,
          phoneNumber: _firebaseUser!.phoneNumber ?? '',
        );
        await _firestoreService.createUser(newUser);
        _userModel = newUser;
        debugPrint('🟢 [AuthProvider] User document created successfully');
      }
    } catch (e) {
      debugPrint('🔴 [AuthProvider] _loadUserModel FAILED: $e');
      _userModel = null;
      _error = 'Failed to load profile. Please restart the app.';
    }
    debugPrint('🔵 [AuthProvider] After _loadUserModel: isLoggedIn=$isLoggedIn, userModel=$_userModel, error=$_error');
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
    debugPrint('🔵 [AuthProvider] _signInWithCredential called');
    try {
      final result = await _authService.signInWithCredential(credential);
      _firebaseUser = result.user;
      debugPrint('🟢 [AuthProvider] Firebase sign-in success: uid=${_firebaseUser?.uid}');

      if (_firebaseUser != null) {
        debugPrint('🔵 [AuthProvider] Checking Firestore for existing user...');
        final existingUser =
            await _firestoreService.getUser(_firebaseUser!.uid);
        if (existingUser == null) {
          debugPrint('🟡 [AuthProvider] New user — creating Firestore document');
          final newUser = UserModel(
            uid: _firebaseUser!.uid,
            phoneNumber: _firebaseUser!.phoneNumber ?? '',
          );
          await _firestoreService.createUser(newUser);
          _userModel = newUser;
          debugPrint('🟢 [AuthProvider] New user created in Firestore');
        } else {
          _userModel = existingUser;
          debugPrint('🟢 [AuthProvider] Existing user loaded from Firestore');
        }
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 [AuthProvider] FirebaseAuthException during sign-in: code=${e.code}, msg=${e.message}');
      _error = e.message ?? 'Sign in failed';
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('🔴 [AuthProvider] Unknown error during sign-in: $e');
      _error = 'Sign in failed';
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
