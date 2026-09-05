import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/tournament_model.dart';
import '../../providers/tournament_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({super.key});

  String _statusLabel(TournamentStatus s) {
    switch (s) {
      case TournamentStatus.open:
        return 'Inscriptions';
      case TournamentStatus.inProgress:
        return 'En cours';
      case TournamentStatus.completed:
        return 'Terminé';
      case TournamentStatus.cancelled:
        return 'Annulé';
    }
  }

  Color _statusColor(TournamentStatus s) {
    switch (s) {
      case TournamentStatus.open:
        return AppColors.success;
      case TournamentStatus.inProgress:
        return AppColors.info;
      case TournamentStatus.completed:
        return AppColors.gold;
      case TournamentStatus.cancelled:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(tournamentsProvider);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tournois'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/tournaments/create'),
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events_outlined,
                        size: 56,
                        color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun tournoi',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Crée le premier tournoi de la communauté',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.push('/tournaments/create'),
                      child: const Text('Créer un tournoi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final t = list[i];
              final joined = uid != null && t.isParticipant(uid);
              return GestureDetector(
                onTap: () => context.push('/tournaments/${t.id}'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: joined
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.emoji_events,
                            color: AppColors.gold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${t.playerCount}/${t.maxPlayers} joueurs · ${t.country}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(t.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel(t.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(t.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tournaments/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.emoji_events),
        label: const Text('Créer',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
