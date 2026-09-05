import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/team_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/team_provider.dart';

class TeamDetailScreen extends ConsumerWidget {
  final String teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTeamAsync = ref.watch(userTeamProvider);
    final currentUid = ref.watch(authStateProvider).valueOrNull?.uid;

    // Re-use stream if it's the user's team, otherwise one-shot fetch via open list
    // For simplicity we watch user team and also load members when we have the team
    return userTeamAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erreur: $e')),
      ),
      data: (myTeam) {
        // If viewing own team
        if (myTeam != null && myTeam.id == teamId) {
          return _TeamDetailBody(
            team: myTeam,
            currentUid: currentUid,
            isMember: true,
          );
        }

        // Otherwise load from open teams or stream
        return _OtherTeamDetail(teamId: teamId, currentUid: currentUid);
      },
    );
  }
}

class _OtherTeamDetail extends ConsumerStatefulWidget {
  final String teamId;
  final String? currentUid;

  const _OtherTeamDetail({required this.teamId, this.currentUid});

  @override
  ConsumerState<_OtherTeamDetail> createState() => _OtherTeamDetailState();
}

class _OtherTeamDetailState extends ConsumerState<_OtherTeamDetail> {
  TeamModel? _team;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stream = ref.read(teamServiceProvider).streamTeam(widget.teamId);
      final team = await stream.first;
      if (mounted) {
        setState(() {
          _team = team;
          _loading = false;
          if (team == null) _error = 'Équipe introuvable';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_error != null || _team == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Équipe introuvable')),
      );
    }

    final myTeam = ref.watch(userTeamProvider).valueOrNull;
    final isMember = _team!.memberIds.contains(widget.currentUid);

    return _TeamDetailBody(
      team: _team!,
      currentUid: widget.currentUid,
      isMember: isMember,
      canJoin: myTeam == null && _team!.isOpen && !isMember,
    );
  }
}

class _TeamDetailBody extends ConsumerWidget {
  final TeamModel team;
  final String? currentUid;
  final bool isMember;
  final bool canJoin;

  const _TeamDetailBody({
    required this.team,
    required this.currentUid,
    required this.isMember,
    this.canJoin = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(teamMembersProvider(team.memberIds));
    final isOwner = team.ownerId == currentUid;
    final isLoading = ref.watch(teamControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(team.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: isOwner
                      ? () async {
                          final picker = ImagePicker();
                          final x = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 512,
                            maxHeight: 512,
                            imageQuality: 85,
                          );
                          if (x == null) return;
                          await ref
                              .read(teamControllerProvider.notifier)
                              .uploadLogo(team.id, File(x.path));
                          final st = ref.read(teamControllerProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(st.hasError
                                    ? st.error.toString()
                                    : 'Logo mis à jour'),
                                backgroundColor: st.hasError
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                            );
                          }
                        }
                      : null,
                  child: Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(18),
                          image: team.logoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(team.logoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: team.logoUrl == null
                            ? const Icon(Icons.shield,
                                color: AppColors.info, size: 36)
                            : null,
                      ),
                      if (isOwner)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 12, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (team.description != null && team.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    team.description!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Chip(label: '${team.memberCount} membres'),
                    const SizedBox(width: 8),
                    _Chip(label: team.country),
                    const SizedBox(width: 8),
                    _Chip(
                      label: team.isOpen ? 'Ouverte' : 'Fermée',
                      color: team.isOpen ? AppColors.success : AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _Stat(label: 'Victoires', value: '${team.stats.wins}'),
                _Stat(label: 'Défaites', value: '${team.stats.losses}'),
                _Stat(label: 'Points', value: '${team.stats.points}'),
                _Stat(label: 'Trophées', value: '${team.stats.trophies}'),
              ],
            ),
          ),

          const SizedBox(height: 16),
          if (isMember)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/teams/${team.id}/battles'),
                icon: const Icon(Icons.sports_mma, size: 18),
                label: const Text('Clan Wars'),
              ),
            ),

          const SizedBox(height: 24),

          const Text(
            'Membres',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          membersAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => Text('Erreur: $e'),
            data: (members) {
              return Column(
                children: members.map((m) {
                  final isTeamOwner = m.uid == team.ownerId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.surfaceLight,
                          child: Text(
                            m.username.isNotEmpty
                                ? m.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${m.stats.rank} · ${m.stats.points} pts',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isTeamOwner)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Owner',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        if (isOwner && !isTeamOwner)
                          IconButton(
                            icon: const Icon(Icons.person_remove,
                                size: 20, color: AppColors.error),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        backgroundColor: AppColors.surface,
                                        title: const Text('Exclure ?'),
                                        content: Text(
                                            'Exclure ${m.username} de l\'équipe ?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text(
                                              'Exclure',
                                              style: TextStyle(
                                                  color: AppColors.error),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref
                                          .read(teamControllerProvider.notifier)
                                          .kickMember(team.id, m.uid);
                                    }
                                  },
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 28),

          // Actions
          if (canJoin)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        await ref
                            .read(teamControllerProvider.notifier)
                            .joinTeam(team.id);
                        final state = ref.read(teamControllerProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.hasError
                                  ? state.error.toString()
                                  : 'Équipe rejointe !'),
                              backgroundColor: state.hasError
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          );
                          if (!state.hasError) context.go('/teams');
                        }
                      },
                child: const Text('Rejoindre l\'équipe'),
              ),
            ),

          if (isMember) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: const Text('Quitter l\'équipe ?'),
                            content: Text(isOwner
                                ? 'Tu es le propriétaire. L\'ownership sera transféré ou l\'équipe supprimée.'
                                : 'Es-tu sûr de vouloir quitter ${team.name} ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Quitter',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(teamControllerProvider.notifier)
                              .leaveTeam(team.id);
                          if (context.mounted) context.go('/teams');
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Quitter l\'équipe'),
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;

  const _Chip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
