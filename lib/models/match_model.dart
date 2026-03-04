import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final String userId1;
  final String userId2;
  final DateTime matchedAt;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  MatchModel({
    required this.id,
    required this.userId1,
    required this.userId2,
    DateTime? matchedAt,
    this.lastMessage,
    this.lastMessageAt,
  }) : matchedAt = matchedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'users': [userId1, userId2],
      'matchedAt': Timestamp.fromDate(matchedAt),
      'lastMessage': lastMessage,
      'lastMessageAt':
          lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
    };
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] ?? '',
      userId1: map['userId1'] ?? '',
      userId2: map['userId2'] ?? '',
      matchedAt: (map['matchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: map['lastMessage'],
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }

  String getOtherUserId(String currentUserId) {
    return userId1 == currentUserId ? userId2 : userId1;
  }
}
