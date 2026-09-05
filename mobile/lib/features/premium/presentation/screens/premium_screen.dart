import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/premium_provider.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  static const _benefits = [
    ('Badges exclusifs', 'Montre ton statut Premium sur ton profil', Icons.workspace_premium),
    ('Profil mis en avant', 'Apparais plus haut dans les recherches', Icons.star_rounded),
    ('Stats avancées', 'Historiques détaillés et tendances', Icons.insights_rounded),
    ('Tournois Premium', 'Accès aux compétitions exclusives', Icons.emoji_events),
    ('Personnalisation', 'Thèmes et effets de profil', Icons.palette_rounded),
    ('Sans publicité', 'Expérience 100% focus compétition', Icons.block),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isPremium = user?.isPremium == true;
    final isLoading = ref.watch(premiumControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Premium'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.25),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium,
                    size: 56, color: AppColors.gold),
                const SizedBox(height: 12),
                Text(
                  isPremium ? 'Tu es Premium ✨' : 'eFoot Arena Premium',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isPremium
                      ? 'Profite de tous les avantages compétitifs'
                      : 'Passe au niveau supérieur. Compete. Dominate. Rise.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Text(
            'Avantages',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          ..._benefits.map((b) {
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(b.$3, color: AppColors.gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.$1,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(b.$2,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Pricing mock
          if (!isPremium) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1 mois',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('Essai / offre de lancement',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  Text(
                    'Gratuit*',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '*Paiement réel (Play Store / IAP) à brancher plus tard. '
              'Pour l’instant, activation manuelle pour tester.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Activer Premium (30 jours)',
              isLoading: isLoading,
              icon: Icons.workspace_premium,
              onPressed: () async {
                await ref.read(premiumControllerProvider.notifier).activate();
                final s = ref.read(premiumControllerProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(s.hasError
                          ? s.error.toString()
                          : 'Premium activé 30 jours !'),
                      backgroundColor:
                          s.hasError ? AppColors.error : AppColors.success,
                    ),
                  );
                }
              },
            ),
          ] else ...[
            PrimaryButton(
              text: 'Gérer / désactiver (test)',
              isLoading: isLoading,
              isOutlined: true,
              onPressed: () async {
                await ref.read(premiumControllerProvider.notifier).deactivate();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Premium désactivé'),
                      backgroundColor: AppColors.textMuted,
                    ),
                  );
                }
              },
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
