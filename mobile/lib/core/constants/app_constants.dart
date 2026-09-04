class AppConstants {
  // App Info
  static const String appName = 'eFoot Arena';
  static const String appSlogan = 'Compete. Dominate. Rise.';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String teamsCollection = 'teams';
  static const String challengesCollection = 'challenges';
  static const String matchesCollection = 'matches';
  static const String rankingsCollection = 'rankings';

  // Ranks
  static const List<String> ranks = [
    'Bronze',
    'Silver',
    'Gold',
    'Elite',
    'Legendary',
  ];

  // Points thresholds for ranks
  static const Map<String, int> rankThresholds = {
    'Bronze': 0,
    'Silver': 500,
    'Gold': 1500,
    'Elite': 3500,
    'Legendary': 7000,
  };

  // Challenge
  static const int challengeExpiryHours = 24;
  static const int maxActiveChallenges = 5;

  // Team
  static const int maxTeamMembers = 20;
  static const int minTeamNameLength = 3;
  static const int maxTeamNameLength = 20;

  // Username
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 15;

  // Regions (Afrique focus)
  static const List<String> africanCountries = [
    'Sénégal',
    'Côte d\'Ivoire',
    'Cameroun',
    'Nigeria',
    'Ghana',
    'Maroc',
    'Algérie',
    'Tunisie',
    'Égypte',
    'Kenya',
    'Afrique du Sud',
    'Mali',
    'Burkina Faso',
    'Guinée',
    'Togo',
    'Bénin',
    'Congo',
    'RD Congo',
    'Gabon',
    'Autre',
  ];

  static const List<String> regions = [
    'Afrique de l\'Ouest',
    'Afrique Centrale',
    'Afrique du Nord',
    'Afrique de l\'Est',
    'Afrique Australe',
    'International',
  ];
}
