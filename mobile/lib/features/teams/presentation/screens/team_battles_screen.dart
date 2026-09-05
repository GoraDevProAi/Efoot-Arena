import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/team_battle_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/team_battle_provider.dart';

class TeamBattlesScreen extends ConsumerWidget {
  final String teamId;

  const TeamBattlesScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battlesAsync = ref.watch(teamBattlesProvider(teamId));
    final myTeam = ref.watch(userTeamProvider).valueOrNull;
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final isAdmin = myTeam != null &&
        myTeam.id == teamId &&
        uid != null &&
        (myTeam.isOwner(uid) || myTeam.isAdmin(uid));
    final isLoading = ref.watch(teamBattleControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clan Wars'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              onPressed: () => context.push('/teams/$teamId/challenge'),
              icon: const Icon(Icons.add_circle, color: AppColors.primary),
              tooltip: 'Défier une équipe',
            ),
        ],
      ),
      body: battlesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (battles) {
          if (battles.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_moon_outlined,
                        size: 56,
                        color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucune battle',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Défie une autre équipe pour lancer une Clan War',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: battles.length,
            itemBuilder: (context, i) {
              final b = battles[i];
              final isChallenger = b.challengerTeamId == teamId;
              final otherTeamId =
                  isChallenger ? b.opponentTeamId : b.challengerTeamId;

              return _BattleCard(
                battle: b,
                teamId: teamId,
                otherTeamId: otherTeamId,
                isChallenger: isChallenger,
                isAdmin: isAdmin,
                isLoading: isLoading,
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/teams/$teamId/challenge'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.sports_mma),
              label: const Text('Défier',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }
}

class _BattleCard extends ConsumerWidget {
  final TeamBattleModel battle;
  final String teamId;
  final String otherTeamId;
  final bool isChallenger;
  final bool isAdmin;
  final bool isLoading;

  const _BattleCard({
    required this.battle,
    required this.teamId,
    required this.otherTeamId,
    required this.isChallenger,
    required this.isAdmin,
    required this.isLoading,
  });

  String _statusLabel(TeamBattleStatus s) {
    switch (s) {
      case TeamBattleStatus.pending:
        return 'En attente';
      case TeamBattleStatus.accepted:
        return 'Acceptée';
      case TeamBattleStatus.completed:
        return 'Terminée';
      case TeamBattleStatus.declined:
        return 'Refusée';
      case TeamBattleStatus.cancelled:
        return 'Annulée';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = battle;
    final isOpponentSide = !isChallenger;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: AppColors.info, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isChallenger ? 'Tu as défié' : 'Battle reçue',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                _statusLabel(b.status),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'vs équipe · $otherTeamId',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (b.status == TeamBattleStatus.completed &&
              b.challengerScore != null) ...[
            const SizedBox(height: 10),
            Text(
              '${b.challengerScore} — ${b.opponentScore}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800),
            ),
            if (b.winnerTeamId == teamId)
              const Text('🏆 Victoire',
                  style: TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.w600)),
            if (b.winnerTeamId != null && b.winnerTeamId != teamId)
              const Text('Défaite',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.w600)),
          ],
          if (b.status == TeamBattleStatus.pending &&
              isOpponentSide &&
              isAdmin) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => ref
                            .read(teamBattleControllerProvider.notifier)
                            .decline(b.id, teamId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => ref
                            .read(teamBattleControllerProvider.notifier)
                            .accept(b.id, teamId),
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
          ],
          if (b.status == TeamBattleStatus.accepted && isAdmin) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () => _showReportSheet(context, ref, b),
                child: const Text('Reporter le score'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReportSheet(
      BuildContext context, WidgetRef ref, TeamBattleModel b) {
    int cScore = 0;
    int oScore = 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Score Clan War',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ScoreCol(
                        label: 'Challenger',
                        value: cScore,
                        onMinus: () => setModal(
                            () => cScore = (cScore - 1).clamp(0, 20)),
                        onPlus: () =>
                            setModal(() => cScore = (cScore + 1).clamp(0, 20)),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('—', style: TextStyle(fontSize: 24)),
                      ),
                      _ScoreCol(
                        label: 'Adversaire',
                        value: oScore,
                        onMinus: () => setModal(
                            () => oScore = (oScore - 1).clamp(0, 20)),
                        onPlus: () =>
                            setModal(() => oScore = (oScore + 1).clamp(0, 20)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(teamBattleControllerProvider.notifier)
                            .reportResult(
                              battleId: b.id,
                              teamId: teamId,
                              challengerScore: cScore,
                              opponentScore: oScore,
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Valider'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ScoreCol extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _ScoreCol({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Row(
          children: [
            IconButton(onPressed: onMinus, icon: const Icon(Icons.remove)),
            Text('$value',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            IconButton(onPressed: onPlus, icon: const Icon(Icons.add)),
          ],
        ),
      ],
    );
  }
}
