import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final int wins;
  final int losses;
  final double winrate;
  final int currentStreak;
  final int bestStreak;
  final int points;
  final String rank; // Bronze, Silver, Gold, Elite, Legendary
  final int rankPosition;

  const UserStats({
    this.wins = 0,
    this.losses = 0,
    this.winrate = 0.0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.points = 0,
    this.rank = 'Bronze',
    this.rankPosition = 0,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      winrate: (map['winrate'] ?? 0.0).toDouble(),
      currentStreak: map['currentStreak'] ?? 0,
      bestStreak: map['bestStreak'] ?? 0,
      points: map['points'] ?? 0,
      rank: map['rank'] ?? 'Bronze',
      rankPosition: map['rankPosition'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wins': wins,
      'losses': losses,
      'winrate': winrate,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'points': points,
      'rank': rank,
      'rankPosition': rankPosition,
    };
  }

  UserStats copyWith({
    int? wins,
    int? losses,
    double? winrate,
    int? currentStreak,
    int? bestStreak,
    int? points,
    String? rank,
    int? rankPosition,
  }) {
    return UserStats(
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      winrate: winrate ?? this.winrate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      rankPosition: rankPosition ?? this.rankPosition,
    );
  }

  @override
  List<Object?> get props => [
        wins,
        losses,
        winrate,
        currentStreak,
        bestStreak,
        points,
        rank,
        rankPosition,
      ];
}

class UserModel extends Equatable {
  final String uid;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String country;
  final String region;
  final String? teamId;
  final UserStats stats;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isOnline;

  const UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.bio,
    required this.country,
    required this.region,
    this.teamId,
    this.stats = const UserStats(),
    this.isPremium = false,
    required this.createdAt,
    required this.lastActive,
    this.isOnline = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'],
      avatarUrl: data['avatarUrl'],
      bio: data['bio'],
      country: data['country'] ?? '',
      region: data['region'] ?? '',
      teamId: data['teamId'],
      stats: UserStats.fromMap(data['stats'] ?? {}),
      isPremium: data['isPremium'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOnline: data['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'country': country,
      'region': region,
      'teamId': teamId,
      'stats': stats.toMap(),
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'isOnline': isOnline,
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? country,
    String? region,
    String? teamId,
    UserStats? stats,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isOnline,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      region: region ?? this.region,
      teamId: teamId ?? this.teamId,
      stats: stats ?? this.stats,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        username,
        email,
        displayName,
        avatarUrl,
        bio,
        country,
        region,
        teamId,
        stats,
        isPremium,
        createdAt,
        lastActive,
        isOnline,
      ];
}
