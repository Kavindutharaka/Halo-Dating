import 'package:halo/models/user_model.dart';
import 'package:halo/models/match_model.dart';
import 'package:halo/models/message_model.dart';

class MockData {
  // Mock current logged-in user
  static final UserModel currentUser = UserModel(
    uid: 'mock_current_user',
    phoneNumber: '+94767378686',
    name: 'Kavindu',
    dateOfBirth: DateTime(2003, 5, 14),
    gender: Gender.male,
    city: 'Colombo',
    bio: 'Software engineer who loves hiking and street food. Looking for something real.',
    photoUrls: [
      'https://randomuser.me/api/portraits/men/32.jpg',
      'https://randomuser.me/api/portraits/men/33.jpg',
    ],
    isPremium: true,
    isVerified: false,
    verificationStatus: VerificationStatus.none,
    isProfileComplete: true,
    personalityAnswers: {
      'Two truths and a lie about me…': 'I speak 3 languages, I\'ve been to Japan, I hate spicy food',
      'The key to my heart is…': 'Good conversations and bad movies',
      'My love language is…': 'Quality time',
      'Green flags I look for…': 'Kindness and ambition',
      'One thing I will never tolerate…': 'Dishonesty',
    },
    lifestyleAnswers: {
      'My typical Sunday looks like…': 'Morning coffee, gym, then exploring Colombo 7',
      'Tea or coffee?': 'Coffee — always coffee',
      'Colombo life or peaceful hometown?': 'Colombo life, but weekend escapes to hometown',
    },
    relationshipAnswers: {
      "I'm looking for…": 'A genuine connection that grows into something serious',
      'My ideal date night…': 'Rooftop dinner then stargazing',
    },
    funAnswers: {
      'Dating me is like…': 'A road trip — unexpected detours but always worth it',
    },
  );

  // Mock profiles to discover
  static final List<UserModel> discoverProfiles = [
    UserModel(
      uid: 'mock_user_1',
      phoneNumber: '+94771234567',
      name: 'Nisali',
      dateOfBirth: DateTime(2001, 8, 22),
      gender: Gender.female,
      city: 'Kandy',
      bio: 'Architecture student who paints on weekends. Tea over coffee, always.',
      photoUrls: [
        'https://randomuser.me/api/portraits/women/44.jpg',
        'https://randomuser.me/api/portraits/women/45.jpg',
        'https://randomuser.me/api/portraits/women/46.jpg',
      ],
      isPremium: true,
      isVerified: true,
      verificationStatus: VerificationStatus.approved,
      isProfileComplete: true,
      personalityAnswers: {
        'Two truths and a lie about me…': 'I can cook 20+ dishes, I\'ve never watched a horror film, I have a twin',
        'The key to my heart is…': 'Surprise picnics and handwritten notes',
        'My love language is…': 'Acts of service',
        'Green flags I look for…': 'Someone who is kind to strangers',
        'One thing I will never tolerate…': 'Being taken for granted',
      },
      lifestyleAnswers: {
        'My typical Sunday looks like…': 'Farmer\'s market, then painting at home',
        'Tea or coffee?': 'Tea — I\'m from Kandy after all!',
        'Colombo life or peaceful hometown?': 'Peaceful hometown always',
        'My simple pleasures…': 'Rain, a good book, and hot tea',
      },
      relationshipAnswers: {
        "I'm looking for…": 'Someone who makes ordinary days feel special',
        'My ideal date night…': 'Cooking together and watching old films',
        "We'll get along if…": 'You can talk for hours about anything',
      },
      funAnswers: {
        'Dating me is like…': 'Finding a hidden gem café — worth every step',
        "Let's debate this…": 'Pineapple on kottu? Absolutely yes.',
      },
    ),
    UserModel(
      uid: 'mock_user_2',
      phoneNumber: '+94712345678',
      name: 'Tharushi',
      dateOfBirth: DateTime(2000, 3, 10),
      gender: Gender.female,
      city: 'Colombo',
      bio: 'Doctor in training. I laugh too loud and care too much — not sorry about either.',
      photoUrls: [
        'https://randomuser.me/api/portraits/women/68.jpg',
        'https://randomuser.me/api/portraits/women/69.jpg',
      ],
      isPremium: false,
      isVerified: true,
      verificationStatus: VerificationStatus.approved,
      isProfileComplete: true,
      personalityAnswers: {
        'My love language is…': 'Words of affirmation',
        'Green flags I look for…': 'Emotional intelligence and a good sense of humor',
      },
      lifestyleAnswers: {
        'My typical Sunday looks like…': 'Hospital volunteering, then brunch with friends',
        'Tea or coffee?': 'Neither — I live on energy drinks',
        'I get excited about…': 'New research, travel plans, and good food',
      },
      relationshipAnswers: {
        "I'm looking for…": 'A partner who pushes me to grow',
        'My ideal date night…': 'Something adventurous — night hike or street food tour',
      },
      funAnswers: {
        'Dating me is like…': 'Grey\'s Anatomy — dramatic but you can\'t stop watching',
      },
    ),
    UserModel(
      uid: 'mock_user_3',
      phoneNumber: '+94751234567',
      name: 'Dilini',
      dateOfBirth: DateTime(1999, 11, 5),
      gender: Gender.female,
      city: 'Galle',
      bio: 'Marine biologist by day, surfer by evening. The ocean is my home.',
      photoUrls: [
        'https://randomuser.me/api/portraits/women/22.jpg',
        'https://randomuser.me/api/portraits/women/23.jpg',
        'https://randomuser.me/api/portraits/women/24.jpg',
      ],
      isPremium: false,
      isVerified: false,
      verificationStatus: VerificationStatus.none,
      isProfileComplete: true,
      personalityAnswers: {
        'Two truths and a lie about me…': 'I\'ve swum with whale sharks, I\'ve never left Sri Lanka, I speak Japanese',
        'The key to my heart is…': 'Love for nature and animals',
      },
      lifestyleAnswers: {
        'My typical Sunday looks like…': 'Sunrise surf, beach cleanup, then fresh seafood',
        'Colombo life or peaceful hometown?': 'Galle forever — Colombo is too loud',
        'My simple pleasures…': 'Barefoot on the beach at sunset',
      },
      relationshipAnswers: {
        "I'm looking for…": 'Someone who can appreciate the simple beauty of life',
        'Together we could…': 'Travel every coast of Sri Lanka',
      },
      funAnswers: {
        "Let's debate this…": 'Sri Lanka has the best beaches in the world. Not a debate.',
      },
    ),
    UserModel(
      uid: 'mock_user_4',
      phoneNumber: '+94761234567',
      name: 'Chamodi',
      dateOfBirth: DateTime(2002, 6, 18),
      gender: Gender.female,
      city: 'Negombo',
      bio: 'Fashion design student with a thing for vintage everything. Currently obsessed with film photography.',
      photoUrls: [
        'https://randomuser.me/api/portraits/women/55.jpg',
        'https://randomuser.me/api/portraits/women/56.jpg',
      ],
      isPremium: false,
      isVerified: false,
      verificationStatus: VerificationStatus.pending,
      isProfileComplete: true,
      personalityAnswers: {
        'My love language is…': 'Gift giving — I notice details',
        'Green flags I look for…': 'Creative, curious, and kind',
      },
      lifestyleAnswers: {
        'Tea or coffee?': 'Coffee with oat milk',
        'I get excited about…': 'Vintage markets, gallery openings, and film developing day',
        'My simple pleasures…': 'Finding the perfect thrift store find',
      },
      relationshipAnswers: {
        'My ideal date night…': 'Art gallery then a long walk with good music',
        "We'll get along if…": 'You have a favourite film director',
      },
      funAnswers: {
        'Dating me is like…': 'A perfectly curated playlist — different every time but always good',
        "Let's debate this…": 'Film photos > digital. No contest.',
      },
    ),
    UserModel(
      uid: 'mock_user_5',
      phoneNumber: '+94781234567',
      name: 'Hasini',
      dateOfBirth: DateTime(1998, 9, 30),
      gender: Gender.female,
      city: 'Nuwara Eliya',
      bio: 'Tea estate manager and proud hill country girl. I can name 30 types of tea. Challenge me.',
      photoUrls: [
        'https://randomuser.me/api/portraits/women/77.jpg',
        'https://randomuser.me/api/portraits/women/78.jpg',
      ],
      isPremium: false,
      isVerified: true,
      verificationStatus: VerificationStatus.approved,
      isProfileComplete: true,
      personalityAnswers: {
        'Two truths and a lie about me…': 'I wake up at 4am daily, I\'ve met the President, I hate tea',
        'The key to my heart is…': 'Appreciating where things come from',
        'One thing I will never tolerate…': 'Wastefulness',
      },
      lifestyleAnswers: {
        'My typical Sunday looks like…': 'Estate walk at dawn, then farmers market',
        'Tea or coffee?': 'Tea. I manage a tea estate. What kind of question is this?',
        'Colombo life or peaceful hometown?': 'Nuwara Eliya hills — Colombo visits me, not the other way around',
      },
      relationshipAnswers: {
        "I'm looking for…": 'Someone grounded and genuine',
        'Together we could…': 'Build something meaningful and live slowly',
      },
      funAnswers: {
        'Dating me is like…': 'A good cup of tea — takes time to steep but worth the wait',
      },
    ),
  ];

  // Mock matches
  static final List<MatchModel> matches = [
    MatchModel(
      id: 'mock_match_1',
      userId1: 'mock_current_user',
      userId2: 'mock_user_1',
      matchedAt: DateTime.now().subtract(const Duration(hours: 2)),
      lastMessage: 'Hey Kavindu! 👋',
      lastMessageAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    MatchModel(
      id: 'mock_match_2',
      userId1: 'mock_current_user',
      userId2: 'mock_user_2',
      matchedAt: DateTime.now().subtract(const Duration(days: 1)),
      lastMessage: 'Are you free this weekend?',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    MatchModel(
      id: 'mock_match_3',
      userId1: 'mock_current_user',
      userId2: 'mock_user_3',
      matchedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Mock messages per match
  static final Map<String, List<MessageModel>> messages = {
    'mock_match_1': [
      MessageModel(
        id: 'msg_1',
        senderId: 'mock_user_1',
        text: 'Hey Kavindu! 👋',
        sentAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      MessageModel(
        id: 'msg_2',
        senderId: 'mock_current_user',
        text: 'Hey Nisali! Great to match with you 😊',
        sentAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      MessageModel(
        id: 'msg_3',
        senderId: 'mock_user_1',
        text: 'I saw you\'re from Colombo — do you ever visit Kandy?',
        sentAt: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      MessageModel(
        id: 'msg_4',
        senderId: 'mock_current_user',
        text: 'Yes! I love Kandy. The lake, the Temple of the Tooth — it\'s beautiful',
        sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      MessageModel(
        id: 'msg_5',
        senderId: 'mock_user_1',
        text: 'Next time you\'re here I can show you the hidden spots 🌿',
        sentAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ],
    'mock_match_2': [
      MessageModel(
        id: 'msg_6',
        senderId: 'mock_current_user',
        text: 'Hi Tharushi! A doctor in training — respect! 🙌',
        sentAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      MessageModel(
        id: 'msg_7',
        senderId: 'mock_user_2',
        text: 'Haha thanks! It\'s intense but I love it',
        sentAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      MessageModel(
        id: 'msg_8',
        senderId: 'mock_user_2',
        text: 'Are you free this weekend?',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
  };
}
