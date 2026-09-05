import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Réglages'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionTitle('Compte'),
          _Tile(
            icon: Icons.edit_outlined,
            title: 'Modifier le profil',
            onTap: () => context.push('/profile/edit'),
          ),
          _Tile(
            icon: Icons.workspace_premium,
            title: 'Premium',
            color: AppColors.gold,
            onTap: () => context.push('/premium'),
          ),
          const _SectionTitle('Communauté'),
          _Tile(
            icon: Icons.chat_bubble_outline,
            title: 'Chat communautaire',
            onTap: () => context.push('/chat'),
          ),
          _Tile(
            icon: Icons.movie_filter_outlined,
            title: 'Highlights',
            onTap: () => context.push('/highlights'),
          ),
          _Tile(
            icon: Icons.storefront_outlined,
            title: 'Marketplace',
            onTap: () => context.push('/marketplace'),
          ),
          _Tile(
            icon: Icons.emoji_events_outlined,
            title: 'Tournois',
            onTap: () => context.push('/tournaments'),
          ),
          const _SectionTitle('Compétition'),
          _Tile(
            icon: Icons.sports_esports_outlined,
            title: 'Défis 1v1',
            onTap: () => context.go('/challenges'),
          ),
          _Tile(
            icon: Icons.groups_outlined,
            title: 'Équipes',
            onTap: () => context.go('/teams'),
          ),
          _Tile(
            icon: Icons.leaderboard_outlined,
            title: 'Classement',
            onTap: () => context.go('/ranking'),
          ),
          const _SectionTitle('Session'),
          _Tile(
            icon: Icons.logout,
            title: 'Déconnexion',
            color: AppColors.error,
            onTap: () {
              ref.read(authControllerProvider.notifier).signOut();
              context.go('/login');
            },
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'eFoot Arena · v1.0.0',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: c),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: c),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
    );
  }
}
