import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TeamBattleStatus {
  pending,
  accepted,
  declined,
  completed,
  cancelled,
}

class TeamBattleModel extends Equatable {
  final String id;
  final String challengerTeamId;
  final String opponentTeamId;
  final String challengedByUserId;
  final TeamBattleStatus status;
  final int? challengerScore;
  final int? opponentScore;
  final String? winnerTeamId;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TeamBattleModel({
    required this.id,
    required this.challengerTeamId,
    required this.opponentTeamId,
    required this.challengedByUserId,
    required this.status,
    this.challengerScore,
    this.opponentScore,
    this.winnerTeamId,
    required this.createdAt,
    this.completedAt,
  });

  factory TeamBattleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamBattleModel(
      id: doc.id,
      challengerTeamId: data['challengerTeamId'] ?? '',
      opponentTeamId: data['opponentTeamId'] ?? '',
      challengedByUserId: data['challengedByUserId'] ?? '',
      status: TeamBattleStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TeamBattleStatus.pending,
      ),
      challengerScore: data['challengerScore'],
      opponentScore: data['opponentScore'],
      winnerTeamId: data['winnerTeamId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        challengerTeamId,
        opponentTeamId,
        challengedByUserId,
        status,
        challengerScore,
        opponentScore,
        winnerTeamId,
        createdAt,
        completedAt,
      ];
}
