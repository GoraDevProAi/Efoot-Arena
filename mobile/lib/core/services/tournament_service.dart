import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/tournament_model.dart';

class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _tournaments =>
      _firestore.collection('tournaments');

  Future<String> createTournament({
    required String name,
    required String creatorId,
    required String country,
    required String region,
    String? description,
    int maxPlayers = 8,
  }) async {
    final trimmed = name.trim();
    if (trimmed.length < 3) {
      throw Exception('Nom trop court (min. 3 caractères)');
    }
    if (maxPlayers < 2 || maxPlayers > 32) {
      throw Exception('Entre 2 et 32 joueurs');
    }

    final now = DateTime.now();
    final doc = await _tournaments.add({
      'name': trimmed,
      'description': description?.trim(),
      'creatorId': creatorId,
      'participantIds': [creatorId],
      'maxPlayers': maxPlayers,
      'status': TournamentStatus.open.name,
      'region': region,
      'country': country,
      'createdAt': Timestamp.fromDate(now),
      'startsAt': null,
      'winnerId': null,
    });
    return doc.id;
  }

  Future<void> joinTournament(String tournamentId, String userId) async {
    final doc = await _tournaments.doc(tournamentId).get();
    if (!doc.exists) throw Exception('Tournoi introuvable');

    final data = doc.data() as Map<String, dynamic>;
    final participants = List<String>.from(data['participantIds'] ?? []);
    final maxPlayers = data['maxPlayers'] ?? 8;
    final status = data['status'] as String? ?? 'open';

    if (status != TournamentStatus.open.name) {
      throw Exception('Ce tournoi n\'accepte plus d\'inscriptions');
    }
    if (participants.contains(userId)) {
      throw Exception('Tu es déjà inscrit');
    }
    if (participants.length >= maxPlayers) {
      throw Exception('Tournoi complet');
    }

    await _tournaments.doc(tournamentId).update({
      'participantIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> leaveTournament(String tournamentId, String userId) async {
    final doc = await _tournaments.doc(tournamentId).get();
    if (!doc.exists) throw Exception('Tournoi introuvable');

    final data = doc.data() as Map<String, dynamic>;
    if (data['status'] != TournamentStatus.open.name) {
      throw Exception('Impossible de se désinscrire maintenant');
    }
    if (data['creatorId'] == userId) {
      throw Exception('Le créateur ne peut pas quitter. Annule le tournoi.');
    }

    await _tournaments.doc(tournamentId).update({
      'participantIds': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> startTournament(String tournamentId, String userId) async {
    final doc = await _tournaments.doc(tournamentId).get();
    if (!doc.exists) throw Exception('Tournoi introuvable');

    final data = doc.data() as Map<String, dynamic>;
    if (data['creatorId'] != userId) {
      throw Exception('Seul le créateur peut démarrer');
    }
    final participants = List<String>.from(data['participantIds'] ?? []);
    if (participants.length < 2) {
      throw Exception('Il faut au moins 2 joueurs');
    }

    await _tournaments.doc(tournamentId).update({
      'status': TournamentStatus.inProgress.name,
      'startsAt': Timestamp.now(),
    });
  }

  Future<void> cancelTournament(String tournamentId, String userId) async {
    final doc = await _tournaments.doc(tournamentId).get();
    if (!doc.exists) throw Exception('Tournoi introuvable');
    final data = doc.data() as Map<String, dynamic>;
    if (data['creatorId'] != userId) {
      throw Exception('Non autorisé');
    }
    await _tournaments.doc(tournamentId).update({
      'status': TournamentStatus.cancelled.name,
    });
  }

  Future<void> setWinner({
    required String tournamentId,
    required String userId,
    required String winnerId,
  }) async {
    final doc = await _tournaments.doc(tournamentId).get();
    if (!doc.exists) throw Exception('Tournoi introuvable');
    final data = doc.data() as Map<String, dynamic>;
    if (data['creatorId'] != userId) {
      throw Exception('Seul le créateur peut déclarer le vainqueur');
    }
    final participants = List<String>.from(data['participantIds'] ?? []);
    if (!participants.contains(winnerId)) {
      throw Exception('Le vainqueur doit être inscrit');
    }

    await _tournaments.doc(tournamentId).update({
      'status': TournamentStatus.completed.name,
      'winnerId': winnerId,
    });
  }

  Stream<List<TournamentModel>> streamTournaments({int limit = 40}) {
    return _tournaments
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TournamentModel.fromFirestore(d)).toList());
  }

  Stream<TournamentModel?> streamTournament(String id) {
    return _tournaments.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TournamentModel.fromFirestore(doc);
    });
  }
}
