import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/team_model.dart';
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';

class TeamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _teams =>
      _firestore.collection(AppConstants.teamsCollection);

  CollectionReference get _users =>
      _firestore.collection(AppConstants.usersCollection);

  /// Create a new team
  Future<String> createTeam({
    required String name,
    required String ownerId,
    required String country,
    required String region,
    String? description,
    bool isOpen = true,
  }) async {
    final trimmed = name.trim();
    if (trimmed.length < AppConstants.minTeamNameLength) {
      throw Exception(
          'Le nom doit faire au moins ${AppConstants.minTeamNameLength} caractères');
    }
    if (trimmed.length > AppConstants.maxTeamNameLength) {
      throw Exception(
          'Le nom ne peut pas dépasser ${AppConstants.maxTeamNameLength} caractères');
    }

    // Check if user already has a team
    final userDoc = await _users.doc(ownerId).get();
    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      if (data['teamId'] != null && (data['teamId'] as String).isNotEmpty) {
        throw Exception('Tu es déjà dans une équipe. Quitte-la d\'abord.');
      }
    }

    // Check name uniqueness (case-insensitive via lowercase)
    final nameQuery = await _teams
        .where('nameLower', isEqualTo: trimmed.toLowerCase())
        .limit(1)
        .get();
    if (nameQuery.docs.isNotEmpty) {
      throw Exception('Ce nom d\'équipe est déjà pris');
    }

    final now = DateTime.now();
    final doc = await _teams.add({
      'name': trimmed,
      'nameLower': trimmed.toLowerCase(),
      'logoUrl': null,
      'description': description?.trim(),
      'ownerId': ownerId,
      'memberIds': [ownerId],
      'adminIds': [ownerId],
      'stats': {
        'wins': 0,
        'losses': 0,
        'winrate': 0.0,
        'points': 0,
        'trophies': 0,
      },
      'country': country,
      'region': region,
      'createdAt': Timestamp.fromDate(now),
      'isOpen': isOpen,
    });

    // Update user with teamId
    await _users.doc(ownerId).update({'teamId': doc.id});

    return doc.id;
  }

  /// Join an open team
  Future<void> joinTeam(String teamId, String userId) async {
    final teamDoc = await _teams.doc(teamId).get();
    if (!teamDoc.exists) throw Exception('Équipe introuvable');

    final data = teamDoc.data() as Map<String, dynamic>;
    final memberIds = List<String>.from(data['memberIds'] ?? []);

    if (memberIds.contains(userId)) {
      throw Exception('Tu es déjà membre de cette équipe');
    }
    if (memberIds.length >= AppConstants.maxTeamMembers) {
      throw Exception('Cette équipe est complète');
    }
    if (data['isOpen'] != true) {
      throw Exception('Cette équipe est sur invitation uniquement');
    }

    // Check user not already in a team
    final userDoc = await _users.doc(userId).get();
    if (userDoc.exists) {
      final udata = userDoc.data() as Map<String, dynamic>;
      if (udata['teamId'] != null && (udata['teamId'] as String).isNotEmpty) {
        throw Exception('Tu es déjà dans une équipe');
      }
    }

    final batch = _firestore.batch();
    batch.update(_teams.doc(teamId), {
      'memberIds': FieldValue.arrayUnion([userId]),
    });
    batch.update(_users.doc(userId), {'teamId': teamId});
    await batch.commit();
  }

  /// Leave team
  Future<void> leaveTeam(String teamId, String userId) async {
    final teamDoc = await _teams.doc(teamId).get();
    if (!teamDoc.exists) throw Exception('Équipe introuvable');

    final data = teamDoc.data() as Map<String, dynamic>;
    final ownerId = data['ownerId'] as String;
    final memberIds = List<String>.from(data['memberIds'] ?? []);

    if (!memberIds.contains(userId)) {
      throw Exception('Tu n\'es pas membre de cette équipe');
    }

    if (ownerId == userId) {
      // Owner leaving: if only member, delete team; else transfer ownership
      if (memberIds.length == 1) {
        final batch = _firestore.batch();
        batch.delete(_teams.doc(teamId));
        batch.update(_users.doc(userId), {'teamId': null});
        await batch.commit();
        return;
      }
      // Transfer to first other member
      final newOwner = memberIds.firstWhere((id) => id != userId);
      final batch = _firestore.batch();
      batch.update(_teams.doc(teamId), {
        'ownerId': newOwner,
        'memberIds': FieldValue.arrayRemove([userId]),
        'adminIds': FieldValue.arrayUnion([newOwner]),
      });
      // Remove from admin if was admin
      batch.update(_teams.doc(teamId), {
        'adminIds': FieldValue.arrayRemove([userId]),
      });
      batch.update(_users.doc(userId), {'teamId': null});
      await batch.commit();
      return;
    }

    final batch = _firestore.batch();
    batch.update(_teams.doc(teamId), {
      'memberIds': FieldValue.arrayRemove([userId]),
      'adminIds': FieldValue.arrayRemove([userId]),
    });
    batch.update(_users.doc(userId), {'teamId': null});
    await batch.commit();
  }

  /// Kick a member (owner/admin only)
  Future<void> kickMember({
    required String teamId,
    required String kickerId,
    required String memberId,
  }) async {
    final teamDoc = await _teams.doc(teamId).get();
    if (!teamDoc.exists) throw Exception('Équipe introuvable');

    final data = teamDoc.data() as Map<String, dynamic>;
    final ownerId = data['ownerId'] as String;
    final adminIds = List<String>.from(data['adminIds'] ?? []);

    if (kickerId != ownerId && !adminIds.contains(kickerId)) {
      throw Exception('Non autorisé');
    }
    if (memberId == ownerId) {
      throw Exception('Impossible d\'exclure le propriétaire');
    }

    final batch = _firestore.batch();
    batch.update(_teams.doc(teamId), {
      'memberIds': FieldValue.arrayRemove([memberId]),
      'adminIds': FieldValue.arrayRemove([memberId]),
    });
    batch.update(_users.doc(memberId), {'teamId': null});
    await batch.commit();
  }

  Stream<TeamModel?> streamTeam(String teamId) {
    return _teams.doc(teamId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TeamModel.fromFirestore(doc);
    });
  }

  Stream<TeamModel?> streamUserTeam(String userId) {
    return _users.doc(userId).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) return null;
      final data = userDoc.data() as Map<String, dynamic>?;
      final teamId = data?['teamId'] as String?;
      if (teamId == null || teamId.isEmpty) return null;
      final teamDoc = await _teams.doc(teamId).get();
      if (!teamDoc.exists) return null;
      return TeamModel.fromFirestore(teamDoc);
    });
  }

  /// Browse open teams
  Future<List<TeamModel>> getOpenTeams({int limit = 30}) async {
    final snapshot = await _teams
        .where('isOpen', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => TeamModel.fromFirestore(doc)).toList();
  }

  /// Search teams by name
  Future<List<TeamModel>> searchTeams(String query) async {
    if (query.trim().length < 2) return [];
    final q = query.trim().toLowerCase();
    final snapshot = await _teams
        .where('nameLower', isGreaterThanOrEqualTo: q)
        .where('nameLower', isLessThanOrEqualTo: '$q\uf8ff')
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => TeamModel.fromFirestore(doc)).toList();
  }

  Future<List<UserModel>> getTeamMembers(List<String> memberIds) async {
    if (memberIds.isEmpty) return [];
    // Firestore whereIn limit is 30
    final chunks = <List<String>>[];
    for (var i = 0; i < memberIds.length; i += 10) {
      chunks.add(memberIds.sublist(
        i,
        i + 10 > memberIds.length ? memberIds.length : i + 10,
      ));
    }

    final members = <UserModel>[];
    for (final chunk in chunks) {
      final snapshot = await _users
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      members.addAll(
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)),
      );
    }
    return members;
  }

  Future<void> updateTeam({
    required String teamId,
    required String userId,
    String? description,
    bool? isOpen,
  }) async {
    final teamDoc = await _teams.doc(teamId).get();
    if (!teamDoc.exists) throw Exception('Équipe introuvable');

    final data = teamDoc.data() as Map<String, dynamic>;
    final ownerId = data['ownerId'] as String;
    final adminIds = List<String>.from(data['adminIds'] ?? []);

    if (userId != ownerId && !adminIds.contains(userId)) {
      throw Exception('Non autorisé');
    }

    final updates = <String, dynamic>{};
    if (description != null) updates['description'] = description.trim();
    if (isOpen != null) updates['isOpen'] = isOpen;

    if (updates.isNotEmpty) {
      await _teams.doc(teamId).update(updates);
    }
  }
}
