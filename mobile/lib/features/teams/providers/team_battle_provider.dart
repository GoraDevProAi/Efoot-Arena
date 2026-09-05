import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/team_battle_service.dart';
import '../../../shared/models/team_battle_model.dart';
import '../../../shared/models/team_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'team_provider.dart';

final teamBattleServiceProvider = Provider<TeamBattleService>((ref) {
  return TeamBattleService();
});

final teamBattlesProvider =
    StreamProvider.family<List<TeamBattleModel>, String>((ref, teamId) {
  return ref.watch(teamBattleServiceProvider).streamTeamBattles(teamId);
});

class TeamBattleController extends StateNotifier<AsyncValue<void>> {
  final TeamBattleService _service;
  final Ref _ref;

  TeamBattleController(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> challenge({
    required String challengerTeamId,
    required String opponentTeamId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.createBattle(
        challengerTeamId: challengerTeamId,
        opponentTeamId: opponentTeamId,
        userId: user.uid,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(teamBattlesProvider(challengerTeamId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> accept(String battleId, String teamId) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.acceptBattle(battleId, user.uid);
      state = const AsyncValue.data(null);
      _ref.invalidate(teamBattlesProvider(teamId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> decline(String battleId, String teamId) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.declineBattle(battleId, user.uid);
      state = const AsyncValue.data(null);
      _ref.invalidate(teamBattlesProvider(teamId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reportResult({
    required String battleId,
    required String teamId,
    required int challengerScore,
    required int opponentScore,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.reportResult(
        battleId: battleId,
        userId: user.uid,
        challengerScore: challengerScore,
        opponentScore: opponentScore,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(teamBattlesProvider(teamId));
      _ref.invalidate(userTeamProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final teamBattleControllerProvider =
    StateNotifierProvider<TeamBattleController, AsyncValue<void>>((ref) {
  return TeamBattleController(ref.watch(teamBattleServiceProvider), ref);
});
