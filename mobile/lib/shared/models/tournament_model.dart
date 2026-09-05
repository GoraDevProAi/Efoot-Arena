import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TournamentStatus { open, inProgress, completed, cancelled }

class TournamentModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String creatorId;
  final List<String> participantIds;
  final int maxPlayers;
  final TournamentStatus status;
  final String region;
  final String country;
  final DateTime createdAt;
  final DateTime? startsAt;
  final String? winnerId;

  const TournamentModel({
    required this.id,
    required this.name,
    this.description,
    required this.creatorId,
    required this.participantIds,
    required this.maxPlayers,
    required this.status,
    required this.region,
    required this.country,
    required this.createdAt,
    this.startsAt,
    this.winnerId,
  });

  factory TournamentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TournamentModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      creatorId: data['creatorId'] ?? '',
      participantIds: List<String>.from(data['participantIds'] ?? []),
      maxPlayers: data['maxPlayers'] ?? 8,
      status: TournamentStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TournamentStatus.open,
      ),
      region: data['region'] ?? '',
      country: data['country'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startsAt: (data['startsAt'] as Timestamp?)?.toDate(),
      winnerId: data['winnerId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'participantIds': participantIds,
      'maxPlayers': maxPlayers,
      'status': status.name,
      'region': region,
      'country': country,
      'createdAt': Timestamp.fromDate(createdAt),
      'startsAt': startsAt != null ? Timestamp.fromDate(startsAt!) : null,
      'winnerId': winnerId,
    };
  }

  int get playerCount => participantIds.length;
  bool get isFull => playerCount >= maxPlayers;
  bool get isOpen => status == TournamentStatus.open && !isFull;

  bool isParticipant(String uid) => participantIds.contains(uid);
  bool isCreator(String uid) => creatorId == uid;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        creatorId,
        participantIds,
        maxPlayers,
        status,
        region,
        country,
        createdAt,
        startsAt,
        winnerId,
      ];
}
