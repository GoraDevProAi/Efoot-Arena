import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/challenge_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../core/services/challenge_service.dart';
import '../../providers/challenge_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class ChallengeCard extends ConsumerStatefulWidget {
  final ChallengeModel challenge;
  final VoidCallback? onReportResult;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onReportResult,
  });

  @override
  ConsumerState<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends ConsumerState<ChallengeCard> {
  UserModel? _opponent;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadOpponent();
  }

  Future<void> _loadOpponent() async {
    final currentUid = ref.read(authStateProvider).valueOrNull?.uid;
    final opponentId = widget.challenge.challengerId == currentUid
        ? widget.challenge.opponentId
        : widget.challenge.challengerId;

    final user = await ref.read(challengeServiceProvider).getUser(opponentId);
    if (mounted) {
      setState(() {
        _opponent = user;
        _loadingUser = false;
      });
    }
  }

  String _statusLabel(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.pending:
        return 'En attente';
      case ChallengeStatus.accepted:
        return 'En cours';
      case ChallengeStatus.completed:
        return 'Terminé';
      case ChallengeStatus.declined:
        return 'Refusé';
      case ChallengeStatus.cancelled:
        return 'Annulé';
      case ChallengeStatus.expired:
        return 'Expiré';
    }
  }

  Color _statusColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.pending:
        return AppColors.warning;
      case ChallengeStatus.accepted:
        return AppColors.info;
      case ChallengeStatus.completed:
        return AppColors.success;
      case ChallengeStatus.declined:
      case ChallengeStatus.cancelled:
      case ChallengeStatus.expired:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = ref.watch(authStateProvider).valueOrNull?.uid;
    final isChallenger = widget.challenge.challengerId == currentUid;
    final isOpponent = widget.challenge.opponentId == currentUid;
    final c = widget.challenge;
    final controller = ref.watch(challengeControllerProvider);
    final isLoading = controller.isLoading;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: opponent + status
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _loadingUser
                    ? const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Center(
                        child: Text(
                          (_opponent?.username.isNotEmpty == true
                                  ? _opponent!.username[0]
                                  : '?')
                              .toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _loadingUser
                          ? '...'
                          : (_opponent?.username ?? 'Joueur'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isChallenger ? 'Tu as défié' : 'T\'a défié',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(c.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(c.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(c.status),
                  ),
                ),
              ),
            ],
          ),

          // Message
          if (c.message != null && c.message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '"${c.message}"',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Score if completed
          if (c.status == ChallengeStatus.completed &&
              c.challengerScore != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${c.challengerScore}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: c.winnerId == c.challengerId
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '—',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  Text(
                    '${c.opponentScore}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: c.winnerId == c.opponentId
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (c.winnerId != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    c.winnerId == currentUid ? '🏆 Victoire' : 'Défaite',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: c.winnerId == currentUid
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
              ),
          ],

          // Actions
          if (c.status == ChallengeStatus.pending && isOpponent) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => ref
                            .read(challengeControllerProvider.notifier)
                            .decline(c.id),
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
                            .read(challengeControllerProvider.notifier)
                            .accept(c.id),
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
          ],

          if (c.status == ChallengeStatus.pending && isChallenger) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () => ref
                        .read(challengeControllerProvider.notifier)
                        .cancel(c.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Text('Annuler le défi'),
              ),
            ),
          ],

          if (c.status == ChallengeStatus.accepted) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : widget.onReportResult,
                icon: const Icon(Icons.sports_score, size: 18),
                label: const Text('Reporter le score'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
