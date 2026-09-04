import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Chargement...'));
          }
          return _ProfileContent(user: user);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserModel user;

  const _ProfileContent({required this.user});

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar + username
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: user.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : const Icon(Icons.person, size: 48, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _rankColor(user.stats.rank).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _rankColor(user.stats.rank).withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              user.stats.rank,
              style: TextStyle(
                color: _rankColor(user.stats.rank),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Stats grid
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _ProfileStat(
                      label: 'Victoires',
                      value: '${user.stats.wins}',
                      color: AppColors.success,
                    ),
                    _ProfileStat(
                      label: 'Défaites',
                      value: '${user.stats.losses}',
                      color: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _ProfileStat(
                      label: 'Winrate',
                      value: '${user.stats.winrate.toStringAsFixed(1)}%',
                      color: AppColors.info,
                    ),
                    _ProfileStat(
                      label: 'Points',
                      value: '${user.stats.points}',
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _ProfileStat(
                      label: 'Série actuelle',
                      value: '${user.stats.currentStreak}',
                      color: AppColors.warning,
                    ),
                    _ProfileStat(
                      label: 'Meilleure série',
                      value: '${user.stats.bestStreak}',
                      color: AppColors.gold,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _InfoRow(icon: Icons.public, label: 'Pays', value: user.country),
                const Divider(height: 24, color: AppColors.border),
                _InfoRow(icon: Icons.map_outlined, label: 'Région', value: user.region),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const Divider(height: 24, color: AppColors.border),
                  _InfoRow(icon: Icons.info_outline, label: 'Bio', value: user.bio!),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProfileStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
