import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/team_model.dart';
import '../../providers/team_provider.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTeamAsync = ref.watch(userTeamProvider);
    final openTeamsAsync = ref.watch(openTeamsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Équipes'),
        actions: [
          IconButton(
            onPressed: () => context.push('/teams/create'),
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            tooltip: 'Créer une équipe',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(userTeamProvider);
          ref.invalidate(openTeamsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            const Text(
              'Mon équipe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            userTeamAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) => Text('Erreur: $e',
                  style: const TextStyle(color: AppColors.error)),
              data: (team) {
                if (team == null) {
                  return _EmptyMyTeam(
                    onCreate: () => context.push('/teams/create'),
                  );
                }
                return _TeamCard(
                  team: team,
                  isMine: true,
                  onTap: () => context.push('/teams/${team.id}'),
                );
              },
            ),
            const SizedBox(height: 28),
            const Text(
              'Équipes ouvertes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            openTeamsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) => Text('Erreur: $e',
                  style: const TextStyle(color: AppColors.error)),
              data: (teams) {
                final myTeam = userTeamAsync.valueOrNull;
                final filtered = teams
                    .where((t) => myTeam == null || t.id != myTeam.id)
                    .toList();

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text(
                        'Aucune équipe ouverte pour le moment',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  );
                }

                return Column(
                  children: filtered
                      .map((team) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TeamCard(
                              team: team,
                              isMine: false,
                              onTap: () => context.push('/teams/${team.id}'),
                              onJoin: myTeam == null
                                  ? () async {
                                      await ref
                                          .read(teamControllerProvider.notifier)
                                          .joinTeam(team.id);
                                      final state =
                                          ref.read(teamControllerProvider);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(state.hasError
                                                ? state.error.toString()
                                                : 'Équipe rejointe !'),
                                            backgroundColor: state.hasError
                                                ? AppColors.error
                                                : AppColors.success,
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/teams/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.groups),
        label: const Text('Créer', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _EmptyMyTeam extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyMyTeam({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.groups_outlined, size: 48,
              color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          const Text('Tu n\'as pas d\'équipe',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 6),
          const Text(
            'Crée la tienne ou rejoins une équipe ouverte',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCreate,
              child: const Text('Créer mon équipe'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final TeamModel team;
  final bool isMine;
  final VoidCallback onTap;
  final VoidCallback? onJoin;

  const _TeamCard({
    required this.team,
    required this.isMine,
    required this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMine
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield, color: AppColors.info, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(team.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    '${team.memberCount} membres · ${team.country}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (onJoin != null)
              TextButton(
                onPressed: onJoin,
                child: const Text('Rejoindre',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              )
            else
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
