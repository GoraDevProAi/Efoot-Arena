import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../theme/app_theme.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final needsOnboarding = ref.watch(needsOnboardingProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;

      final isAuthRoute = location == '/login' || location == '/register';
      final isOnboarding = location == '/onboarding';

      // Not logged in → force login/register
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Logged in but needs onboarding
      if (isLoggedIn && needsOnboarding && !isOnboarding) {
        return '/onboarding';
      }

      // Logged in + onboarding done → leave auth routes
      if (isLoggedIn && !needsOnboarding && (isAuthRoute || isOnboarding)) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app (placeholder for now)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const _HomePlaceholder(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const _PlaceholderScreen(title: 'Profil'),
      ),
      GoRoute(
        path: '/teams',
        name: 'teams',
        builder: (context, state) => const _PlaceholderScreen(title: 'Équipes'),
      ),
      GoRoute(
        path: '/challenges',
        name: 'challenges',
        builder: (context, state) => const _PlaceholderScreen(title: 'Défis'),
      ),
      GoRoute(
        path: '/ranking',
        name: 'ranking',
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Classement'),
      ),
    ],
  );
});

class _HomePlaceholder extends ConsumerWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('eFoot Arena'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'eF',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Bienvenue${user != null ? ', ${user.username}' : ''} !',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Home en cours de construction...\nLes défis, équipes et classements arrivent bientôt.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              if (user != null) ...[
                _InfoChip(label: 'Pays', value: user.country),
                const SizedBox(height: 8),
                _InfoChip(label: 'Région', value: user.region),
                const SizedBox(height: 8),
                _InfoChip(label: 'Rang', value: user.stats.rank),
                const SizedBox(height: 8),
                _InfoChip(
                  label: 'Points',
                  value: '${user.stats.points}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title — bientôt disponible',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
