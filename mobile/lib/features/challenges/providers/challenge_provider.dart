import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/challenge_service.dart';
import '../../../shared/models/challenge_model.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

final challengeServiceProvider = Provider<ChallengeService>((ref) {
  return ChallengeService();
});

final userChallengesProvider = StreamProvider<List<ChallengeModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(challengeServiceProvider).streamUserChallenges(user.uid);
});

final pendingChallengesProvider = Provider<List<ChallengeModel>>((ref) {
  final challenges = ref.watch(userChallengesProvider).valueOrNull ?? [];
  return challenges.where((c) => c.status == ChallengeStatus.pending).toList();
});

final activeChallengesProvider = Provider<List<ChallengeModel>>((ref) {
  final challenges = ref.watch(userChallengesProvider).valueOrNull ?? [];
  return challenges.where((c) => c.status == ChallengeStatus.accepted).toList();
});

final completedChallengesProvider = Provider<List<ChallengeModel>>((ref) {
  final challenges = ref.watch(userChallengesProvider).valueOrNull ?? [];
  return challenges
      .where((c) =>
          c.status == ChallengeStatus.completed ||
          c.status == ChallengeStatus.declined ||
          c.status == ChallengeStatus.cancelled)
      .toList();
});

class ChallengeController extends StateNotifier<AsyncValue<void>> {
  final ChallengeService _service;
  final Ref _ref;

  ChallengeController(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createChallenge({
    required String opponentId,
    String? message,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');

      await _service.createChallenge(
        challengerId: user.uid,
        opponentId: opponentId,
        message: message,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> accept(String challengeId) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.acceptChallenge(challengeId, user.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> decline(String challengeId) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.declineChallenge(challengeId, user.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancel(String challengeId) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.cancelChallenge(challengeId, user.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reportResult({
    required String challengeId,
    required int challengerScore,
    required int opponentScore,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.reportResult(
        challengeId: challengeId,
        reporterId: user.uid,
        challengerScore: challengerScore,
        opponentScore: opponentScore,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }


  Future<String?> startMatchmaking() async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');

      final opponent =
          await _service.findMatchmakingOpponent(user.uid);
      if (opponent == null) {
        throw Exception('Aucun adversaire disponible pour le moment');
      }

      final id = await _service.createChallenge(
        challengerId: user.uid,
        opponentId: opponent.uid,
        message: 'Matchmaking automatique',
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final user = _ref.read(authStateProvider).valueOrNull;
    return _service.searchUsers(query, excludeUid: user?.uid);
  }
}

final challengeControllerProvider =
    StateNotifierProvider<ChallengeController, AsyncValue<void>>((ref) {
  return ChallengeController(ref.watch(challengeServiceProvider), ref);
});
