import 'dart:async';
import 'package:flutter/material.dart';
import 'package:halo/models/match_model.dart';
import 'package:halo/models/user_model.dart';
import 'package:halo/services/firestore_service.dart';

class MatchProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MatchModel> _matches = [];
  final Map<String, UserModel> _matchedUsers = {};
  bool _isLoading = false;
  StreamSubscription? _matchSubscription;

  List<MatchModel> get matches => _matches;
  Map<String, UserModel> get matchedUsers => _matchedUsers;
  bool get isLoading => _isLoading;

  void listenToMatches(String userId) {
    _matchSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _matchSubscription =
        _firestoreService.getMatches(userId).listen((matches) async {
      _matches = matches;
      for (final match in matches) {
        final otherUserId = match.getOtherUserId(userId);
        if (!_matchedUsers.containsKey(otherUserId)) {
          final user = await _firestoreService.getUser(otherUserId);
          if (user != null) {
            _matchedUsers[otherUserId] = user;
          }
        }
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  UserModel? getMatchedUser(String matchId, String currentUserId) {
    final match = _matches.firstWhere(
      (m) => m.id == matchId,
      orElse: () => MatchModel(id: '', userId1: '', userId2: ''),
    );
    if (match.id.isEmpty) return null;
    final otherUserId = match.getOtherUserId(currentUserId);
    return _matchedUsers[otherUserId];
  }

  @override
  void dispose() {
    _matchSubscription?.cancel();
    super.dispose();
  }
}
