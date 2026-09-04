import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/challenge_provider.dart';
import '../widgets/challenge_card.dart';
import '../widgets/report_result_sheet.dart';
import '../../../../shared/models/challenge_model.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
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

  void _showReportResult(ChallengeModel challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportResultSheet(challenge: challenge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingChallengesProvider);
    final active = ref.watch(activeChallengesProvider);
    final completed = ref.watch(completedChallengesProvider);
    final allAsync = ref.watch(userChallengesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Défis'),
        actions: [
          IconButton(
            onPressed: () => context.push('/challenges/create'),
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            tooltip: 'Nouveau défi',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: 'En attente (${pending.length})'),
            Tab(text: 'En cours (${active.length})'),
            Tab(text: 'Historique (${completed.length})'),
          ],
        ),
      ),
      body: allAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text('Erreur: $e', style: const TextStyle(color: AppColors.error)),
        ),
        data: (_) => TabBarView(
          controller: _tabController,
          children: [
            _ChallengeList(
              challenges: pending,
              emptyTitle: 'Aucun défi en attente',
              emptySubtitle: 'Envoie un défi ou attends d\'en recevoir',
              onReportResult: _showReportResult,
            ),
            _ChallengeList(
              challenges: active,
              emptyTitle: 'Aucun défi en cours',
              emptySubtitle: 'Accepte un défi pour commencer à jouer',
              onReportResult: _showReportResult,
            ),
            _ChallengeList(
              challenges: completed,
              emptyTitle: 'Aucun historique',
              emptySubtitle: 'Tes matchs terminés apparaîtront ici',
              onReportResult: _showReportResult,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/challenges/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.sports_esports),
        label: const Text(
          'Défier',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ChallengeList extends StatelessWidget {
  final List<ChallengeModel> challenges;
  final String emptyTitle;
  final String emptySubtitle;
  final void Function(ChallengeModel) onReportResult;

  const _ChallengeList({
    required this.challenges,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onReportResult,
  });

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_esports_rounded,
                size: 56,
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                emptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return ChallengeCard(
          challenge: challenge,
          onReportResult: () => onReportResult(challenge),
        );
      },
    );
  }
}
