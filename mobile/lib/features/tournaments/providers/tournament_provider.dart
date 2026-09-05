import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/tournament_service.dart';
import '../../../shared/models/tournament_model.dart';
import '../../auth/providers/auth_provider.dart';

final tournamentServiceProvider = Provider<TournamentService>((ref) {
  return TournamentService();
});

final tournamentsProvider = StreamProvider<List<TournamentModel>>((ref) {
  return ref.watch(tournamentServiceProvider).streamTournaments();
});

final tournamentProvider =
    StreamProvider.family<TournamentModel?, String>((ref, id) {
  return ref.watch(tournamentServiceProvider).streamTournament(id);
});

class TournamentController extends StateNotifier<AsyncValue<void>> {
  final TournamentService _service;
  final Ref _ref;

  TournamentController(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<String?> create({
    required String name,
    String? description,
    int maxPlayers = 8,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(currentUserProvider).valueOrNull;
      final auth = _ref.read(authStateProvider).valueOrNull;
      if (user == null || auth == null) throw Exception('Non connecté');

      final id = await _service.createTournament(
        name: name,
        creatorId: auth.uid,
        country: user.country,
        region: user.region,
        description: description,
        maxPlayers: maxPlayers,
      );
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> join(String id) async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authStateProvider).valueOrNull;
      if (auth == null) throw Exception('Non connecté');
      await _service.joinTournament(id, auth.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> leave(String id) async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authStateProvider).valueOrNull;
      if (auth == null) throw Exception('Non connecté');
      await _service.leaveTournament(id, auth.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> start(String id) async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authStateProvider).valueOrNull;
      if (auth == null) throw Exception('Non connecté');
      await _service.startTournament(id, auth.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cancel(String id) async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authStateProvider).valueOrNull;
      if (auth == null) throw Exception('Non connecté');
      await _service.cancelTournament(id, auth.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setWinner(String id, String winnerId) async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authStateProvider).valueOrNull;
      if (auth == null) throw Exception('Non connecté');
      await _service.setWinner(
        tournamentId: id,
        userId: auth.uid,
        winnerId: winnerId,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final tournamentControllerProvider =
    StateNotifierProvider<TournamentController, AsyncValue<void>>((ref) {
  return TournamentController(ref.watch(tournamentServiceProvider), ref);
});
