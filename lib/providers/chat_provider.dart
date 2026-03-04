import 'dart:async';
import 'package:flutter/material.dart';
import 'package:halo/models/message_model.dart';
import 'package:halo/services/firestore_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  StreamSubscription? _messageSubscription;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void listenToMessages(String matchId) {
    _messageSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _messageSubscription =
        _firestoreService.getMessages(matchId).listen((messages) {
      _messages = messages;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    await _firestoreService.sendMessage(
      matchId: matchId,
      senderId: senderId,
      text: text,
    );
  }

  void stopListening() {
    _messageSubscription?.cancel();
    _messages = [];
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
