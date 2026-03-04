import 'package:flutter/material.dart';
import 'package:halo/models/user_model.dart';
import 'package:halo/services/firestore_service.dart';

class DiscoverProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<UserModel> _profiles = [];
  bool _isLoading = false;
  String? _error;

  // Filters (premium only)
  String? _cityFilter;
  int? _minAgeFilter;
  int? _maxAgeFilter;

  List<UserModel> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get cityFilter => _cityFilter;
  int? get minAgeFilter => _minAgeFilter;
  int? get maxAgeFilter => _maxAgeFilter;

  void setFilters({String? city, int? minAge, int? maxAge}) {
    _cityFilter = city;
    _minAgeFilter = minAge;
    _maxAgeFilter = maxAge;
    notifyListeners();
  }

  void clearFilters() {
    _cityFilter = null;
    _minAgeFilter = null;
    _maxAgeFilter = null;
    notifyListeners();
  }

  Future<void> loadProfiles({
    required String currentUserId,
    required List<String> blockedUsers,
    bool isPremium = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profiles = await _firestoreService.getDiscoverProfiles(
        currentUserId: currentUserId,
        blockedUsers: blockedUsers,
        cityFilter: isPremium ? _cityFilter : null,
        minAge: isPremium ? _minAgeFilter : null,
        maxAge: isPremium ? _maxAgeFilter : null,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load profiles';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> likeProfile({
    required String fromUserId,
    required String toUserId,
  }) async {
    try {
      final isMatch = await _firestoreService.likeUser(
        fromUserId: fromUserId,
        toUserId: toUserId,
      );
      return isMatch;
    } catch (e) {
      _error = 'Failed to like profile';
      notifyListeners();
      return false;
    }
  }

  void removeProfile(int index) {
    if (index >= 0 && index < _profiles.length) {
      _profiles.removeAt(index);
      notifyListeners();
    }
  }
}
