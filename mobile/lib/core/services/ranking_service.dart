import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';

class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users =>
      _firestore.collection(AppConstants.usersCollection);

  /// Global ranking by points (descending)
  Future<List<UserModel>> getGlobalRanking({int limit = 50}) async {
    final snapshot = await _users
        .orderBy('stats.points', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Regional ranking
  Future<List<UserModel>> getRegionalRanking({
    required String region,
    int limit = 50,
  }) async {
    final snapshot = await _users
        .where('region', isEqualTo: region)
        .orderBy('stats.points', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Country ranking
  Future<List<UserModel>> getCountryRanking({
    required String country,
    int limit = 50,
  }) async {
    final snapshot = await _users
        .where('country', isEqualTo: country)
        .orderBy('stats.points', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Get user's position in global ranking (approximate via points)
  Future<int?> getUserGlobalPosition(String uid, int points) async {
    final higher = await _users
        .where('stats.points', isGreaterThan: points)
        .count()
        .get();
    return (higher.count ?? 0) + 1;
  }
}
