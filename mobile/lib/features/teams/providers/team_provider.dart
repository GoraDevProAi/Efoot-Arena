import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/team_service.dart';
import '../../../shared/models/team_model.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

final teamServiceProvider = Provider<TeamService>((ref) {
  return TeamService();
});

final userTeamProvider = StreamProvider<TeamModel?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref.watch(teamServiceProvider).streamUserTeam(user.uid);
});

final openTeamsProvider = FutureProvider<List<TeamModel>>((ref) {
  return ref.watch(teamServiceProvider).getOpenTeams();
});

final teamMembersProvider =
    FutureProvider.family<List<UserModel>, List<String>>((ref, memberIds) {
  return ref.watch(teamServiceProvider).getTeamMembers(memberIds);
});

class TeamController extends StateNotifier<AsyncValue<void>> {
  final TeamService _service;
  final Ref _ref;

  TeamController(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<String?> createTeam({
    required String name,
    required String country,
    required String region,
    String? description,
    bool isOpen = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');

      final id = await _service.createTeam(
        name: name,
        ownerId: user.uid,
        country: country,
        region: region,
        description: description,
        isOpen: isOpen,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(userTeamProvider);
      _ref.invalidate(openTeamsProvider);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> joinTeam(String teamId) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.joinTeam(teamId, user.uid);
      state = const AsyncValue.data(null);
      _ref.invalidate(userTeamProvider);
      _ref.invalidate(openTeamsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> leaveTeam(String teamId) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.leaveTeam(teamId, user.uid);
      state = const AsyncValue.data(null);
      _ref.invalidate(userTeamProvider);
      _ref.invalidate(openTeamsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> kickMember(String teamId, String memberId) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.kickMember(
        teamId: teamId,
        kickerId: user.uid,
        memberId: memberId,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(userTeamProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }


  Future<void> uploadLogo(String teamId, File file) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.uploadTeamLogo(teamId: teamId, userId: user.uid, file: file);
      state = const AsyncValue.data(null);
      _ref.invalidate(userTeamProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<TeamModel>> searchTeams(String query) {
    return _service.searchTeams(query);
  }
}

final teamControllerProvider =
    StateNotifierProvider<TeamController, AsyncValue<void>>((ref) {
  return TeamController(ref.watch(teamServiceProvider), ref);
});
