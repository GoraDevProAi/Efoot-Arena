import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/tournament_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../challenges/providers/challenge_provider.dart';
import '../../providers/tournament_provider.dart';

class TournamentDetailScreen extends ConsumerWidget {
  final String tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tournamentProvider(tournamentId));
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final isLoading = ref.watch(tournamentControllerProvider).isLoading;

    return async.when(
      loading: () => const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$e')),
      ),
      data: (t) {
        if (t == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Tournoi introuvable')),
          );
        }

        final isCreator = uid != null && t.isCreator(uid);
        final isParticipant = uid != null && t.isParticipant(uid);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(t.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/tournaments'),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events,
                        size: 48, color: AppColors.gold),
                    const SizedBox(height: 12),
                    Text(
                      t.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    if (t.description != null &&
                        t.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        t.description!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      '${t.playerCount} / ${t.maxPlayers} joueurs',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.country} · ${t.region}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Participants',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              ...t.participantIds.map((pid) {
                return FutureBuilder(
                  future: ref.read(challengeServiceProvider).getUser(pid),
                  builder: (context, snap) {
                    final name = snap.data?.username ?? '...';
                    final isWinner = t.winnerId == pid;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isWinner
                              ? AppColors.gold
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.surfaceLight,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (pid == t.creatorId)
                            const Text(
                              'Host',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
                            ),
                          if (isWinner)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text('🏆', style: TextStyle(fontSize: 16)),
                            ),
                          if (isCreator &&
                              t.status == TournamentStatus.inProgress)
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      await ref
                                          .read(tournamentControllerProvider
                                              .notifier)
                                          .setWinner(t.id, pid);
                                    },
                              child: const Text(
                                'Vainqueur',
                                style: TextStyle(
                                    color: AppColors.gold, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 28),

              // Actions
              if (t.status == TournamentStatus.open &&
                  !isParticipant &&
                  !t.isFull)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(tournamentControllerProvider.notifier)
                                .join(t.id);
                            final s = ref.read(tournamentControllerProvider);
                            if (context.mounted && s.hasError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(s.error.toString()),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                    child: const Text('S\'inscrire'),
                  ),
                ),

              if (t.status == TournamentStatus.open &&
                  isParticipant &&
                  !isCreator)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => ref
                            .read(tournamentControllerProvider.notifier)
                            .leave(t.id),
                    child: const Text('Se désinscrire'),
                  ),
                ),

              if (isCreator && t.status == TournamentStatus.open) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => ref
                            .read(tournamentControllerProvider.notifier)
                            .start(t.id),
                    child: const Text('Démarrer le tournoi'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => ref
                            .read(tournamentControllerProvider.notifier)
                            .cancel(t.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Annuler le tournoi'),
                  ),
                ),
              ],

              if (t.status == TournamentStatus.completed)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      'Tournoi terminé',
                      style: TextStyle(
                          color: AppColors.gold, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
