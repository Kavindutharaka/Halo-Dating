import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:halo/models/user_model.dart';
import 'package:halo/models/match_model.dart';
import 'package:halo/models/message_model.dart';
import 'package:halo/models/like_model.dart';
import 'package:halo/models/report_model.dart';
import 'package:halo/utils/constants.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ============ USER OPERATIONS ============

  Future<void> createUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  Future<List<UserModel>> getDiscoverProfiles({
    required String currentUserId,
    required List<String> blockedUsers,
    String? cityFilter,
    int? minAge,
    int? maxAge,
  }) async {
    Query query = _db
        .collection(AppConstants.usersCollection)
        .where('isProfileComplete', isEqualTo: true);

    final snapshot = await query.limit(50).get();

    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((user) {
      if (user.uid == currentUserId) return false;
      if (blockedUsers.contains(user.uid)) return false;
      if (cityFilter != null &&
          cityFilter.isNotEmpty &&
          user.city != cityFilter) {
        return false;
      }
      if (minAge != null && user.age < minAge) return false;
      if (maxAge != null && user.age > maxAge) return false;
      return true;
    }).toList();
  }

  // ============ LIKE OPERATIONS ============

  Future<bool> likeUser({
    required String fromUserId,
    required String toUserId,
  }) async {
    final likeId = '${fromUserId}_$toUserId';
    final like = LikeModel(
      id: likeId,
      fromUserId: fromUserId,
      toUserId: toUserId,
    );

    await _db
        .collection(AppConstants.likesCollection)
        .doc(likeId)
        .set(like.toMap());

    // Increment daily likes
    final userDoc =
        await _db.collection(AppConstants.usersCollection).doc(fromUserId).get();
    final userData = userDoc.data()!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastReset = (userData['lastLikeResetDate'] as Timestamp?)?.toDate();

    int newCount;
    if (lastReset == null ||
        DateTime(lastReset.year, lastReset.month, lastReset.day)
            .isBefore(today)) {
      newCount = 1;
    } else {
      newCount = (userData['dailyLikesUsed'] as int? ?? 0) + 1;
    }

    await _db.collection(AppConstants.usersCollection).doc(fromUserId).update({
      'dailyLikesUsed': newCount,
      'lastLikeResetDate': Timestamp.fromDate(now),
    });

    // Check for mutual like
    final reverseLikeId = '${toUserId}_$fromUserId';
    final reverseLike = await _db
        .collection(AppConstants.likesCollection)
        .doc(reverseLikeId)
        .get();

    if (reverseLike.exists) {
      await _createMatch(fromUserId, toUserId);
      return true; // Match created
    }

    return false; // No match yet
  }

  Future<void> _createMatch(String userId1, String userId2) async {
    final matchId = _uuid.v4();
    final match = MatchModel(
      id: matchId,
      userId1: userId1,
      userId2: userId2,
    );

    await _db
        .collection(AppConstants.matchesCollection)
        .doc(matchId)
        .set(match.toMap());
  }

  Future<bool> hasUserLiked(String fromUserId, String toUserId) async {
    final likeId = '${fromUserId}_$toUserId';
    final doc =
        await _db.collection(AppConstants.likesCollection).doc(likeId).get();
    return doc.exists;
  }

  // ============ MATCH OPERATIONS ============

  Stream<List<MatchModel>> getMatches(String userId) {
    return _db
        .collection(AppConstants.matchesCollection)
        .where('users', arrayContains: userId)
        .orderBy('matchedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MatchModel.fromMap(doc.data()))
            .toList());
  }

  // ============ CHAT / MESSAGE OPERATIONS ============

  Stream<List<MessageModel>> getMessages(String matchId) {
    return _db
        .collection(AppConstants.matchesCollection)
        .doc(matchId)
        .collection(AppConstants.messagesSubcollection)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    final messageId = _uuid.v4();
    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      text: text,
    );

    await _db
        .collection(AppConstants.matchesCollection)
        .doc(matchId)
        .collection(AppConstants.messagesSubcollection)
        .doc(messageId)
        .set(message.toMap());

    // Update match with last message
    await _db
        .collection(AppConstants.matchesCollection)
        .doc(matchId)
        .update({
      'lastMessage': text,
      'lastMessageAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ============ REPORT OPERATIONS ============

  Future<void> reportUser({
    required String reportedByUid,
    required String reportedUserUid,
    required String reason,
    String? details,
  }) async {
    final reportId = _uuid.v4();
    final report = ReportModel(
      id: reportId,
      reportedByUid: reportedByUid,
      reportedUserUid: reportedUserUid,
      reason: reason,
      details: details,
    );

    await _db
        .collection(AppConstants.reportsCollection)
        .doc(reportId)
        .set(report.toMap());
  }

  // ============ BLOCK OPERATIONS ============

  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(currentUserId)
        .update({
      'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
    });
  }

  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(currentUserId)
        .update({
      'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
    });
  }

  // ============ VERIFICATION OPERATIONS ============

  Future<void> submitVerification({
    required String userId,
    required String idPhotoUrl,
    required String selfieUrl,
  }) async {
    await _db
        .collection(AppConstants.verificationsCollection)
        .doc(userId)
        .set({
      'userId': userId,
      'idPhotoUrl': idPhotoUrl,
      'selfieUrl': selfieUrl,
      'status': VerificationStatus.pending.name,
      'submittedAt': Timestamp.fromDate(DateTime.now()),
    });

    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'verificationStatus': VerificationStatus.pending.name,
    });
  }

  // ============ PREMIUM OPERATIONS ============

  Future<void> activatePremium(String userId) async {
    final expiryDate = DateTime.now().add(const Duration(days: 30));
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'isPremium': true,
      'premiumUntil': Timestamp.fromDate(expiryDate),
    });
  }

  Future<void> deactivatePremium(String userId) async {
    await _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'isPremium': false,
      'premiumUntil': null,
    });
  }
}
