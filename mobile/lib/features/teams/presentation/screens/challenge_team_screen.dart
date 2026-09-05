import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/team_provider.dart';
import '../../providers/team_battle_provider.dart';

class ChallengeTeamScreen extends ConsumerWidget {
  final String myTeamId;

  const ChallengeTeamScreen({super.key, required this.myTeamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openTeamsAsync = ref.watch(openTeamsProvider);
    final isLoading = ref.watch(teamBattleControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Défier une équipe'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: openTeamsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (teams) {
          final others = teams.where((t) => t.id != myTeamId).toList();
          if (others.isEmpty) {
            return const Center(
              child: Text(
                'Aucune autre équipe ouverte',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: others.length,
            itemBuilder: (context, i) {
              final team = others[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        image: team.logoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(team.logoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: team.logoUrl == null
                          ? const Icon(Icons.shield,
                              color: AppColors.info, size: 22)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(team.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          Text(
                            '${team.memberCount} membres · ${team.stats.points} pts',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              await ref
                                  .read(teamBattleControllerProvider.notifier)
                                  .challenge(
                                    challengerTeamId: myTeamId,
                                    opponentTeamId: team.id,
                                  );
                              final s =
                                  ref.read(teamBattleControllerProvider);
                              if (context.mounted) {
                                if (s.hasError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(s.error.toString()),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Défi envoyé !'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  context.pop();
                                }
                              }
                            },
                      child: const Text('Défier'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
