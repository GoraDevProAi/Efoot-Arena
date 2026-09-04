import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TeamStats extends Equatable {
  final int wins;
  final int losses;
  final double winrate;
  final int points;
  final int trophies;

  const TeamStats({
    this.wins = 0,
    this.losses = 0,
    this.winrate = 0.0,
    this.points = 0,
    this.trophies = 0,
  });

  factory TeamStats.fromMap(Map<String, dynamic> map) {
    return TeamStats(
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      winrate: (map['winrate'] ?? 0.0).toDouble(),
      points: map['points'] ?? 0,
      trophies: map['trophies'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wins': wins,
      'losses': losses,
      'winrate': winrate,
      'points': points,
      'trophies': trophies,
    };
  }

  @override
  List<Object?> get props => [wins, losses, winrate, points, trophies];
}

class TeamModel extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String? description;
  final String ownerId;
  final List<String> memberIds;
  final List<String> adminIds;
  final TeamStats stats;
  final String country;
  final String region;
  final DateTime createdAt;
  final bool isOpen; // true = anyone can join, false = invite only

  const TeamModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.description,
    required this.ownerId,
    required this.memberIds,
    this.adminIds = const [],
    this.stats = const TeamStats(),
    required this.country,
    required this.region,
    required this.createdAt,
    this.isOpen = true,
  });

  factory TeamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamModel(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'],
      description: data['description'],
      ownerId: data['ownerId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      adminIds: List<String>.from(data['adminIds'] ?? []),
      stats: TeamStats.fromMap(data['stats'] ?? {}),
      country: data['country'] ?? '',
      region: data['region'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOpen: data['isOpen'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'adminIds': adminIds,
      'stats': stats.toMap(),
      'country': country,
      'region': region,
      'createdAt': Timestamp.fromDate(createdAt),
      'isOpen': isOpen,
    };
  }

  int get memberCount => memberIds.length;

  bool isOwner(String userId) => ownerId == userId;
  bool isAdmin(String userId) => adminIds.contains(userId) || isOwner(userId);
  bool isMember(String userId) => memberIds.contains(userId);

  TeamModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? description,
    String? ownerId,
    List<String>? memberIds,
    List<String>? adminIds,
    TeamStats? stats,
    String? country,
    String? region,
    DateTime? createdAt,
    bool? isOpen,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      adminIds: adminIds ?? this.adminIds,
      stats: stats ?? this.stats,
      country: country ?? this.country,
      region: region ?? this.region,
      createdAt: createdAt ?? this.createdAt,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        logoUrl,
        description,
        ownerId,
        memberIds,
        adminIds,
        stats,
        country,
        region,
        createdAt,
        isOpen,
      ];
}
