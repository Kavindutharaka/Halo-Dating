import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female }

enum VerificationStatus { none, pending, approved, rejected }

class UserModel {
  final String uid;
  final String phoneNumber;
  final String name;
  final DateTime dateOfBirth;
  final Gender gender;
  final String city;
  final String bio;
  final List<String> photoUrls;
  final bool isPremium;
  final DateTime? premiumUntil;
  final bool isVerified;
  final VerificationStatus verificationStatus;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime lastActive;
  final List<String> blockedUsers;
  final int dailyLikesUsed;
  final DateTime? lastLikeResetDate;

  // Personality prompts
  final Map<String, String> personalityAnswers;
  final Map<String, String> lifestyleAnswers;
  final Map<String, String> relationshipAnswers;
  final Map<String, String> funAnswers;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.name = '',
    DateTime? dateOfBirth,
    this.gender = Gender.male,
    this.city = '',
    this.bio = '',
    this.photoUrls = const [],
    this.isPremium = false,
    this.premiumUntil,
    this.isVerified = false,
    this.verificationStatus = VerificationStatus.none,
    this.isProfileComplete = false,
    DateTime? createdAt,
    DateTime? lastActive,
    this.blockedUsers = const [],
    this.dailyLikesUsed = 0,
    this.lastLikeResetDate,
    this.personalityAnswers = const {},
    this.lifestyleAnswers = const {},
    this.relationshipAnswers = const {},
    this.funAnswers = const {},
  })  : dateOfBirth = dateOfBirth ?? DateTime(2000, 1, 1),
        createdAt = createdAt ?? DateTime.now(),
        lastActive = lastActive ?? DateTime.now();

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  bool get canLikeToday {
    if (isPremium) return true;
    if (lastLikeResetDate == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastReset = DateTime(
      lastLikeResetDate!.year,
      lastLikeResetDate!.month,
      lastLikeResetDate!.day,
    );
    if (today.isAfter(lastReset)) return true;
    return dailyLikesUsed < 15;
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    DateTime? dateOfBirth,
    Gender? gender,
    String? city,
    String? bio,
    List<String>? photoUrls,
    bool? isPremium,
    DateTime? premiumUntil,
    bool? isVerified,
    VerificationStatus? verificationStatus,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? lastActive,
    List<String>? blockedUsers,
    int? dailyLikesUsed,
    DateTime? lastLikeResetDate,
    Map<String, String>? personalityAnswers,
    Map<String, String>? lifestyleAnswers,
    Map<String, String>? relationshipAnswers,
    Map<String, String>? funAnswers,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      photoUrls: photoUrls ?? this.photoUrls,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      dailyLikesUsed: dailyLikesUsed ?? this.dailyLikesUsed,
      lastLikeResetDate: lastLikeResetDate ?? this.lastLikeResetDate,
      personalityAnswers: personalityAnswers ?? this.personalityAnswers,
      lifestyleAnswers: lifestyleAnswers ?? this.lifestyleAnswers,
      relationshipAnswers: relationshipAnswers ?? this.relationshipAnswers,
      funAnswers: funAnswers ?? this.funAnswers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender.name,
      'city': city,
      'bio': bio,
      'photoUrls': photoUrls,
      'isPremium': isPremium,
      'premiumUntil':
          premiumUntil != null ? Timestamp.fromDate(premiumUntil!) : null,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus.name,
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'blockedUsers': blockedUsers,
      'dailyLikesUsed': dailyLikesUsed,
      'lastLikeResetDate': lastLikeResetDate != null
          ? Timestamp.fromDate(lastLikeResetDate!)
          : null,
      'personalityAnswers': personalityAnswers,
      'lifestyleAnswers': lifestyleAnswers,
      'relationshipAnswers': relationshipAnswers,
      'funAnswers': funAnswers,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate() ??
          DateTime(2000, 1, 1),
      gender: Gender.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => Gender.male,
      ),
      city: map['city'] ?? '',
      bio: map['bio'] ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      isPremium: map['isPremium'] ?? false,
      premiumUntil: (map['premiumUntil'] as Timestamp?)?.toDate(),
      isVerified: map['isVerified'] ?? false,
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == map['verificationStatus'],
        orElse: () => VerificationStatus.none,
      ),
      isProfileComplete: map['isProfileComplete'] ?? false,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive:
          (map['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      dailyLikesUsed: map['dailyLikesUsed'] ?? 0,
      lastLikeResetDate: (map['lastLikeResetDate'] as Timestamp?)?.toDate(),
      personalityAnswers:
          Map<String, String>.from(map['personalityAnswers'] ?? {}),
      lifestyleAnswers:
          Map<String, String>.from(map['lifestyleAnswers'] ?? {}),
      relationshipAnswers:
          Map<String, String>.from(map['relationshipAnswers'] ?? {}),
      funAnswers: Map<String, String>.from(map['funAnswers'] ?? {}),
    );
  }
}
