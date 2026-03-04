class AppConstants {
  static const String appName = 'Halo';
  static const int minAge = 18;
  static const int dailyLikeLimit = 15;
  static const double premiumPriceUsd = 10.0;
  static const String currencyCode = 'USD';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String matchesCollection = 'matches';
  static const String chatsCollection = 'chats';
  static const String messagesSubcollection = 'messages';
  static const String likesCollection = 'likes';
  static const String reportsCollection = 'reports';
  static const String verificationsCollection = 'verifications';

  // Storage paths
  static const String profilePhotosPath = 'profile_photos';
  static const String verificationDocsPath = 'verification_docs';

  // Personality prompts
  static const List<String> personalityPrompts = [
    'Two truths and a lie about me…',
    'The key to my heart is…',
    'My love language is…',
    'Green flags I look for…',
    'One thing I will never tolerate…',
  ];

  // Lifestyle prompts
  static const List<String> lifestylePrompts = [
    'My typical Sunday looks like…',
    'My simple pleasures…',
    'I get excited about…',
    'Colombo life or peaceful hometown?',
    'Tea or coffee?',
  ];

  // Relationship prompts
  static const List<String> relationshipPrompts = [
    "I'm looking for…",
    'My ideal date night…',
    "We'll get along if…",
    'Together we could…',
  ];

  // Fun prompts
  static const List<String> funPrompts = [
    'Dating me is like…',
    "Let's debate this…",
  ];

  // Sri Lankan cities
  static const List<String> sriLankanCities = [
    'Colombo',
    'Kandy',
    'Galle',
    'Jaffna',
    'Negombo',
    'Matara',
    'Batticaloa',
    'Trincomalee',
    'Anuradhapura',
    'Ratnapura',
    'Kurunegala',
    'Badulla',
    'Nuwara Eliya',
    'Hambantota',
    'Kalutara',
    'Gampaha',
    'Polonnaruwa',
    'Matale',
    'Kegalle',
    'Puttalam',
    'Mannar',
    'Vavuniya',
    'Kilinochchi',
    'Mullaitivu',
    'Ampara',
    'Monaragala',
  ];
}
