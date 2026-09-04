import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/challenge_model.dart';
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';
import 'notification_queue.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _challenges =>
      _firestore.collection(AppConstants.challengesCollection);

  CollectionReference get _users =>
      _firestore.collection(AppConstants.usersCollection);

  /// Create a new 1v1 challenge
  Future<String> createChallenge({
    required String challengerId,
    required String opponentId,
    String? message,
  }) async {
    if (challengerId == opponentId) {
      throw Exception('Tu ne peux pas te défier toi-même');
    }

    // Check if there's already a pending challenge between these two
    final existing = await _challenges
        .where('challengerId', isEqualTo: challengerId)
        .where('opponentId', isEqualTo: opponentId)
        .where('status', isEqualTo: ChallengeStatus.pending.name)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Tu as déjà un défi en attente contre ce joueur');
    }

    // Also check reverse direction
    final existingReverse = await _challenges
        .where('challengerId', isEqualTo: opponentId)
        .where('opponentId', isEqualTo: challengerId)
        .where('status', isEqualTo: ChallengeStatus.pending.name)
        .limit(1)
        .get();

    if (existingReverse.docs.isNotEmpty) {
      throw Exception('Ce joueur t\'a déjà envoyé un défi');
    }

    final now = DateTime.now();
    final expiresAt = now.add(
      const Duration(hours: AppConstants.challengeExpiryHours),
    );

    final doc = await _challenges.add({
      'challengerId': challengerId,
      'opponentId': opponentId,
      'status': ChallengeStatus.pending.name,
      'message': message,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'winnerId': null,
      'challengerScore': null,
      'opponentScore': null,
      'acceptedAt': null,
      'completedAt': null,
    });

    // Notify opponent
    try {
      final challenger = await getUser(challengerId);
      await NotificationQueue.challengeReceived(
        toUserId: opponentId,
        fromUsername: challenger?.username ?? 'Un joueur',
      );
    } catch (_) {}

    return doc.id;
  }

  /// Accept a challenge
  Future<void> acceptChallenge(String challengeId, String userId) async {
    final doc = await _challenges.doc(challengeId).get();
    if (!doc.exists) throw Exception('Défi introuvable');

    final data = doc.data() as Map<String, dynamic>;
    if (data['opponentId'] != userId) {
      throw Exception('Seul l\'adversaire peut accepter');
    }
    if (data['status'] != ChallengeStatus.pending.name) {
      throw Exception('Ce défi n\'est plus en attente');
    }

    await _challenges.doc(challengeId).update({
      'status': ChallengeStatus.accepted.name,
      'acceptedAt': Timestamp.now(),
    });

    // Notify challenger
    try {
      final opponent = await getUser(userId);
      await NotificationQueue.challengeAccepted(
        toUserId: data['challengerId'] as String,
        byUsername: opponent?.username ?? 'Un joueur',
      );
    } catch (_) {}
  }

  /// Decline a challenge
  Future<void> declineChallenge(String challengeId, String userId) async {
    final doc = await _challenges.doc(challengeId).get();
    if (!doc.exists) throw Exception('Défi introuvable');

    final data = doc.data() as Map<String, dynamic>;
    if (data['opponentId'] != userId && data['challengerId'] != userId) {
      throw Exception('Non autorisé');
    }

    await _challenges.doc(challengeId).update({
      'status': ChallengeStatus.declined.name,
    });
  }

  /// Cancel own pending challenge
  Future<void> cancelChallenge(String challengeId, String userId) async {
    final doc = await _challenges.doc(challengeId).get();
    if (!doc.exists) throw Exception('Défi introuvable');

    final data = doc.data() as Map<String, dynamic>;
    if (data['challengerId'] != userId) {
      throw Exception('Seul le challenger peut annuler');
    }
    if (data['status'] != ChallengeStatus.pending.name) {
      throw Exception('Ce défi ne peut plus être annulé');
    }

    await _challenges.doc(challengeId).update({
      'status': ChallengeStatus.cancelled.name,
    });
  }

  /// Report match result
  Future<void> reportResult({
    required String challengeId,
    required String reporterId,
    required int challengerScore,
    required int opponentScore,
  }) async {
    final doc = await _challenges.doc(challengeId).get();
    if (!doc.exists) throw Exception('Défi introuvable');

    final data = doc.data() as Map<String, dynamic>;
    final challengerId = data['challengerId'] as String;
    final opponentId = data['opponentId'] as String;

    if (reporterId != challengerId && reporterId != opponentId) {
      throw Exception('Non autorisé');
    }
    if (data['status'] != ChallengeStatus.accepted.name) {
      throw Exception('Le défi doit être accepté pour reporter le score');
    }

    final winnerId = challengerScore > opponentScore
        ? challengerId
        : opponentScore > challengerScore
            ? opponentId
            : null; // draw

    await _challenges.doc(challengeId).update({
      'status': ChallengeStatus.completed.name,
      'challengerScore': challengerScore,
      'opponentScore': opponentScore,
      'winnerId': winnerId,
      'completedAt': Timestamp.now(),
    });

    // Update stats for both players
    if (winnerId != null) {
      final loserId = winnerId == challengerId ? opponentId : challengerId;
      await _updateStatsAfterMatch(winnerId: winnerId, loserId: loserId);
    }
  }

  Future<void> _updateStatsAfterMatch({
    required String winnerId,
    required String loserId,
  }) async {
    final batch = _firestore.batch();

    // Winner
    final winnerRef = _users.doc(winnerId);
    final winnerDoc = await winnerRef.get();
    if (winnerDoc.exists) {
      final stats = Map<String, dynamic>.from(
        (winnerDoc.data() as Map)['stats'] ?? {},
      );
      final wins = (stats['wins'] ?? 0) + 1;
      final losses = stats['losses'] ?? 0;
      final total = wins + losses;
      final currentStreak = (stats['currentStreak'] ?? 0) + 1;
      final bestStreak = currentStreak > (stats['bestStreak'] ?? 0)
          ? currentStreak
          : (stats['bestStreak'] ?? 0);
      final points = (stats['points'] ?? 0) + 25;

      batch.update(winnerRef, {
        'stats.wins': wins,
        'stats.losses': losses,
        'stats.winrate': total > 0 ? (wins / total * 100) : 0.0,
        'stats.currentStreak': currentStreak,
        'stats.bestStreak': bestStreak,
        'stats.points': points,
        'stats.rank': _calculateRank(points),
      });
    }

    // Loser
    final loserRef = _users.doc(loserId);
    final loserDoc = await loserRef.get();
    if (loserDoc.exists) {
      final stats = Map<String, dynamic>.from(
        (loserDoc.data() as Map)['stats'] ?? {},
      );
      final wins = stats['wins'] ?? 0;
      final losses = (stats['losses'] ?? 0) + 1;
      final total = wins + losses;
      final points = ((stats['points'] ?? 0) - 10).clamp(0, 999999);

      batch.update(loserRef, {
        'stats.wins': wins,
        'stats.losses': losses,
        'stats.winrate': total > 0 ? (wins / total * 100) : 0.0,
        'stats.currentStreak': 0,
        'stats.points': points,
        'stats.rank': _calculateRank(points),
      });
    }

    await batch.commit();
  }

  String _calculateRank(int points) {
    if (points >= 7000) return 'Legendary';
    if (points >= 3500) return 'Elite';
    if (points >= 1500) return 'Gold';
    if (points >= 500) return 'Silver';
    return 'Bronze';
  }

  /// Stream challenges for a user (as challenger or opponent)
  Stream<List<ChallengeModel>> streamUserChallenges(String userId) {
    // Firestore doesn't support OR queries easily, so we combine two streams
    // For simplicity, we query where user is challenger OR opponent via two queries
    // and merge in the provider. Here we provide a method for each.

    return _challenges
        .where('challengerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((challengerSnap) async {
      final opponentSnap = await _challenges
          .where('opponentId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final allDocs = [...challengerSnap.docs, ...opponentSnap.docs];
      // Remove duplicates
      final seen = <String>{};
      final challenges = <ChallengeModel>[];

      for (final doc in allDocs) {
        if (seen.add(doc.id)) {
          challenges.add(ChallengeModel.fromFirestore(doc));
        }
      }

      challenges.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return challenges;
    });
  }

  /// Search users by username (for challenging)
  Future<List<UserModel>> searchUsers(String query, {String? excludeUid}) async {
    if (query.trim().length < 2) return [];

    final q = query.trim().toLowerCase();
    final snapshot = await _users
        .where('username', isGreaterThanOrEqualTo: q)
        .where('username', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(15)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((u) => excludeUid == null || u.uid != excludeUid)
        .toList();
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}
