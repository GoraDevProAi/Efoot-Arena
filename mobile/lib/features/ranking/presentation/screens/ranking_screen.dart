import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/ranking_provider.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _rankColor(String rank) {
    switch (rank) {
      case 'Silver':
        return AppColors.silver;
      case 'Gold':
        return AppColors.gold;
      case 'Elite':
        return AppColors.elite;
      case 'Legendary':
        return AppColors.legendary;
      default:
        return AppColors.bronze;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Classement'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Mondial'),
            Tab(text: 'Région'),
            Tab(text: 'Pays'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RankingList(
            provider: globalRankingProvider,
            currentUid: currentUser?.uid,
            rankColor: _rankColor,
            emptyMessage: 'Aucun joueur classé pour le moment',
          ),
          _RankingList(
            provider: regionalRankingProvider,
            currentUid: currentUser?.uid,
            rankColor: _rankColor,
            emptyMessage: currentUser?.region.isNotEmpty == true
                ? 'Aucun joueur dans ta région'
                : 'Région non définie',
            subtitle: currentUser?.region,
          ),
          _RankingList(
            provider: countryRankingProvider,
            currentUid: currentUser?.uid,
            rankColor: _rankColor,
            emptyMessage: currentUser?.country.isNotEmpty == true
                ? 'Aucun joueur dans ton pays'
                : 'Pays non défini',
            subtitle: currentUser?.country,
          ),
        ],
      ),
    );
  }
}

class _RankingList extends ConsumerWidget {
  final FutureProvider<List<UserModel>> provider;
  final String? currentUid;
  final Color Function(String) rankColor;
  final String emptyMessage;
  final String? subtitle;

  const _RankingList({
    required this.provider,
    required this.currentUid,
    required this.rankColor,
    required this.emptyMessage,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(provider);

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text(
                'Erreur de chargement',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '$e\n\nSi Firebase demande un index, crée-le via le lien dans les logs.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(provider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.leaderboard_rounded,
                  size: 56,
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(provider),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: users.length + (subtitle != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (subtitle != null && index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              final i = subtitle != null ? index - 1 : index;
              final user = users[i];
              final position = i + 1;
              final isMe = user.uid == currentUid;

              return _RankRow(
                position: position,
                user: user,
                isMe: isMe,
                rankColor: rankColor(user.stats.rank),
              );
            },
          ),
        );
      },
    );
  }
}

class _RankRow extends StatelessWidget {
  final int position;
  final UserModel user;
  final bool isMe;
  final Color rankColor;

  const _RankRow({
    required this.position,
    required this.user,
    required this.isMe,
    required this.rankColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Position
          SizedBox(
            width: 36,
            child: _PositionBadge(position: position),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceLight,
            child: Text(
              user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + rank
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.username,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isMe ? AppColors.primary : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Toi',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.stats.rank,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: rankColor,
                  ),
                ),
              ],
            ),
          ),
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.stats.points}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                'pts',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  final int position;

  const _PositionBadge({required this.position});

  @override
  Widget build(BuildContext context) {
    Color? medalColor;
    if (position == 1) medalColor = AppColors.gold;
    if (position == 2) medalColor = AppColors.silver;
    if (position == 3) medalColor = AppColors.bronze;

    if (medalColor != null) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: medalColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: medalColor, width: 1.5),
        ),
        child: Center(
          child: Text(
            '$position',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: medalColor,
            ),
          ),
        ),
      );
    }

    return Text(
      '$position',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: AppColors.textMuted,
      ),
    );
  }
}
