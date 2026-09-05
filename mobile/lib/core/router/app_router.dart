import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/challenges/presentation/screens/challenges_screen.dart';
import '../../features/challenges/presentation/screens/create_challenge_screen.dart';
import '../../features/teams/presentation/screens/teams_screen.dart';
import '../../features/teams/presentation/screens/create_team_screen.dart';
import '../../features/teams/presentation/screens/team_detail_screen.dart';
import '../../features/teams/presentation/screens/team_battles_screen.dart';
import '../../features/teams/presentation/screens/challenge_team_screen.dart';
import '../../features/ranking/presentation/screens/ranking_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/tournaments/presentation/screens/tournaments_screen.dart';
import '../../features/tournaments/presentation/screens/create_tournament_screen.dart';
import '../../features/tournaments/presentation/screens/tournament_detail_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';

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

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && needsOnboarding && !isOnboarding) {
        return '/onboarding';
      }

      if (isLoggedIn && !needsOnboarding && (isAuthRoute || isOnboarding)) {
        return '/';
      }

      return null;
    },
    routes: [
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
      GoRoute(
        path: '/challenges/create',
        name: 'createChallenge',
        builder: (context, state) => const CreateChallengeScreen(),
      ),
      GoRoute(
        path: '/teams/create',
        name: 'createTeam',
        builder: (context, state) => const CreateTeamScreen(),
      ),
      GoRoute(
        path: '/teams/:teamId/battles',
        name: 'teamBattles',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return TeamBattlesScreen(teamId: teamId);
        },
      ),
      GoRoute(
        path: '/teams/:teamId/challenge',
        name: 'challengeTeam',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return ChallengeTeamScreen(myTeamId: teamId);
        },
      ),
      GoRoute(
        path: '/teams/:teamId',
        name: 'teamDetail',
        builder: (context, state) {
          final teamId = state.pathParameters['teamId']!;
          return TeamDetailScreen(teamId: teamId);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/tournaments',
        name: 'tournaments',
        builder: (context, state) => const TournamentsScreen(),
      ),
      GoRoute(
        path: '/tournaments/create',
        name: 'createTournament',
        builder: (context, state) => const CreateTournamentScreen(),
      ),
      GoRoute(
        path: '/tournaments/:tournamentId',
        name: 'tournamentDetail',
        builder: (context, state) {
          final id = state.pathParameters['tournamentId']!;
          return TournamentDetailScreen(tournamentId: id);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/challenges',
            name: 'challenges',
            builder: (context, state) => const ChallengesScreen(),
          ),
          GoRoute(
            path: '/teams',
            name: 'teams',
            builder: (context, state) => const TeamsScreen(),
          ),
          GoRoute(
            path: '/ranking',
            name: 'ranking',
            builder: (context, state) => const RankingScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
