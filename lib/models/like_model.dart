import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final DateTime likedAt;

  LikeModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    DateTime? likedAt,
  }) : likedAt = likedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'likedAt': Timestamp.fromDate(likedAt),
    };
  }

  factory LikeModel.fromMap(Map<String, dynamic> map) {
    return LikeModel(
      id: map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      likedAt: (map['likedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
