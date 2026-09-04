import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ChallengeStatus {
  pending,
  accepted,
  declined,
  completed,
  cancelled,
  expired,
}

class ChallengeModel extends Equatable {
  final String id;
  final String challengerId;
  final String opponentId;
  final ChallengeStatus status;
  final String? winnerId;
  final int? challengerScore;
  final int? opponentScore;
  final String? message;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;

  const ChallengeModel({
    required this.id,
    required this.challengerId,
    required this.opponentId,
    required this.status,
    this.winnerId,
    this.challengerScore,
    this.opponentScore,
    this.message,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.expiresAt,
  });

  factory ChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeModel(
      id: doc.id,
      challengerId: data['challengerId'] ?? '',
      opponentId: data['opponentId'] ?? '',
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ChallengeStatus.pending,
      ),
      winnerId: data['winnerId'],
      challengerScore: data['challengerScore'],
      opponentScore: data['opponentScore'],
      message: data['message'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challengerId': challengerId,
      'opponentId': opponentId,
      'status': status.name,
      'winnerId': winnerId,
      'challengerScore': challengerScore,
      'opponentScore': opponentScore,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  bool get isPending => status == ChallengeStatus.pending;
  bool get isAccepted => status == ChallengeStatus.accepted;
  bool get isCompleted => status == ChallengeStatus.completed;

  ChallengeModel copyWith({
    String? id,
    String? challengerId,
    String? opponentId,
    ChallengeStatus? status,
    String? winnerId,
    int? challengerScore,
    int? opponentScore,
    String? message,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? expiresAt,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      challengerId: challengerId ?? this.challengerId,
      opponentId: opponentId ?? this.opponentId,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      challengerScore: challengerScore ?? this.challengerScore,
      opponentScore: opponentScore ?? this.opponentScore,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        challengerId,
        opponentId,
        status,
        winnerId,
        challengerScore,
        opponentScore,
        message,
        createdAt,
        acceptedAt,
        completedAt,
        expiresAt,
      ];
}
