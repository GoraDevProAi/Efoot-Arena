import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/team_battle_model.dart';
import '../constants/app_constants.dart';

class TeamBattleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _battles =>
      _firestore.collection('team_battles');

  CollectionReference get _teams =>
      _firestore.collection(AppConstants.teamsCollection);

  Future<String> createBattle({
    required String challengerTeamId,
    required String opponentTeamId,
    required String userId,
  }) async {
    if (challengerTeamId == opponentTeamId) {
      throw Exception('Tu ne peux pas défier ta propre équipe');
    }

    final teamDoc = await _teams.doc(challengerTeamId).get();
    if (!teamDoc.exists) throw Exception('Équipe introuvable');
    final data = teamDoc.data() as Map<String, dynamic>;
    final ownerId = data['ownerId'] as String;
    final adminIds = List<String>.from(data['adminIds'] ?? []);
    if (userId != ownerId && !adminIds.contains(userId)) {
      throw Exception('Seul le owner/admin peut lancer une battle');
    }

    final existing = await _battles
        .where('challengerTeamId', isEqualTo: challengerTeamId)
        .where('opponentTeamId', isEqualTo: opponentTeamId)
        .where('status', isEqualTo: TeamBattleStatus.pending.name)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('Battle déjà en attente contre cette équipe');
    }

    final doc = await _battles.add({
      'challengerTeamId': challengerTeamId,
      'opponentTeamId': opponentTeamId,
      'challengedByUserId': userId,
      'status': TeamBattleStatus.pending.name,
      'challengerScore': null,
      'opponentScore': null,
      'winnerTeamId': null,
      'createdAt': Timestamp.now(),
      'completedAt': null,
    });
    return doc.id;
  }

  Future<void> acceptBattle(String battleId, String userId) async {
    final doc = await _battles.doc(battleId).get();
    if (!doc.exists) throw Exception('Battle introuvable');
    final data = doc.data() as Map<String, dynamic>;
    if (data['status'] != TeamBattleStatus.pending.name) {
      throw Exception('Cette battle n\'est plus en attente');
    }

    final opponentTeamId = data['opponentTeamId'] as String;
    final teamDoc = await _teams.doc(opponentTeamId).get();
    if (!teamDoc.exists) throw Exception('Équipe adverse introuvable');
    final tdata = teamDoc.data() as Map<String, dynamic>;
    final ownerId = tdata['ownerId'] as String;
    final adminIds = List<String>.from(tdata['adminIds'] ?? []);
    if (userId != ownerId && !adminIds.contains(userId)) {
      throw Exception('Seul le owner/admin adverse peut accepter');
    }

    await _battles.doc(battleId).update({
      'status': TeamBattleStatus.accepted.name,
    });
  }

  Future<void> declineBattle(String battleId, String userId) async {
    final doc = await _battles.doc(battleId).get();
    if (!doc.exists) throw Exception('Battle introuvable');
    final data = doc.data() as Map<String, dynamic>;
    final opponentTeamId = data['opponentTeamId'] as String;
    final teamDoc = await _teams.doc(opponentTeamId).get();
    if (!teamDoc.exists) throw Exception('Équipe introuvable');
    final tdata = teamDoc.data() as Map<String, dynamic>;
    final ownerId = tdata['ownerId'] as String;
    final adminIds = List<String>.from(tdata['adminIds'] ?? []);
    if (userId != ownerId && !adminIds.contains(userId)) {
      throw Exception('Non autorisé');
    }

    await _battles.doc(battleId).update({
      'status': TeamBattleStatus.declined.name,
    });
  }

  Future<void> reportResult({
    required String battleId,
    required String userId,
    required int challengerScore,
    required int opponentScore,
  }) async {
    final doc = await _battles.doc(battleId).get();
    if (!doc.exists) throw Exception('Battle introuvable');
    final data = doc.data() as Map<String, dynamic>;
    if (data['status'] != TeamBattleStatus.accepted.name) {
      throw Exception('La battle doit être acceptée');
    }

    final challengerTeamId = data['challengerTeamId'] as String;
    final opponentTeamId = data['opponentTeamId'] as String;

    // Either side owner/admin can report
    final allowed = await _isTeamAdmin(challengerTeamId, userId) ||
        await _isTeamAdmin(opponentTeamId, userId);
    if (!allowed) throw Exception('Non autorisé');

    String? winnerTeamId;
    if (challengerScore > opponentScore) {
      winnerTeamId = challengerTeamId;
    } else if (opponentScore > challengerScore) {
      winnerTeamId = opponentTeamId;
    }

    await _battles.doc(battleId).update({
      'status': TeamBattleStatus.completed.name,
      'challengerScore': challengerScore,
      'opponentScore': opponentScore,
      'winnerTeamId': winnerTeamId,
      'completedAt': Timestamp.now(),
    });

    if (winnerTeamId != null) {
      final loserId =
          winnerTeamId == challengerTeamId ? opponentTeamId : challengerTeamId;
      await _updateTeamStats(winnerId: winnerTeamId, loserId: loserId);
    }
  }

  Future<bool> _isTeamAdmin(String teamId, String userId) async {
    final doc = await _teams.doc(teamId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    if (data['ownerId'] == userId) return true;
    return List<String>.from(data['adminIds'] ?? []).contains(userId);
  }

  Future<void> _updateTeamStats({
    required String winnerId,
    required String loserId,
  }) async {
    final batch = _firestore.batch();

    final wRef = _teams.doc(winnerId);
    final wDoc = await wRef.get();
    if (wDoc.exists) {
      final stats = Map<String, dynamic>.from(
          (wDoc.data() as Map)['stats'] ?? {});
      final wins = (stats['wins'] ?? 0) + 1;
      final losses = stats['losses'] ?? 0;
      final total = wins + losses;
      batch.update(wRef, {
        'stats.wins': wins,
        'stats.losses': losses,
        'stats.winrate': total > 0 ? (wins / total * 100) : 0.0,
        'stats.points': (stats['points'] ?? 0) + 50,
        'stats.trophies': (stats['trophies'] ?? 0) + 1,
      });
    }

    final lRef = _teams.doc(loserId);
    final lDoc = await lRef.get();
    if (lDoc.exists) {
      final stats = Map<String, dynamic>.from(
          (lDoc.data() as Map)['stats'] ?? {});
      final wins = stats['wins'] ?? 0;
      final losses = (stats['losses'] ?? 0) + 1;
      final total = wins + losses;
      batch.update(lRef, {
        'stats.wins': wins,
        'stats.losses': losses,
        'stats.winrate': total > 0 ? (wins / total * 100) : 0.0,
        'stats.points': ((stats['points'] ?? 0) - 20).clamp(0, 999999),
      });
    }

    await batch.commit();
  }

  Stream<List<TeamBattleModel>> streamTeamBattles(String teamId) {
    return _battles
        .where('challengerTeamId', isEqualTo: teamId)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .asyncMap((challengerSnap) async {
      final opponentSnap = await _battles
          .where('opponentTeamId', isEqualTo: teamId)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      final seen = <String>{};
      final list = <TeamBattleModel>[];
      for (final doc in [...challengerSnap.docs, ...opponentSnap.docs]) {
        if (seen.add(doc.id)) {
          list.add(TeamBattleModel.fromFirestore(doc));
        }
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
