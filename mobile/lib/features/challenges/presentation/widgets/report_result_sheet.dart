import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/challenge_model.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/challenge_provider.dart';

class ReportResultSheet extends ConsumerStatefulWidget {
  final ChallengeModel challenge;

  const ReportResultSheet({super.key, required this.challenge});

  @override
  ConsumerState<ReportResultSheet> createState() => _ReportResultSheetState();
}

class _ReportResultSheetState extends ConsumerState<ReportResultSheet> {
  int _challengerScore = 0;
  int _opponentScore = 0;

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(challengeControllerProvider).isLoading;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Reporter le score',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Entre le score final du match eFootball',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ScoreSelector(
                label: 'Challenger',
                value: _challengerScore,
                onChanged: (v) => setState(() => _challengerScore = v),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '—',
                  style: TextStyle(
                    fontSize: 28,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              _ScoreSelector(
                label: 'Adversaire',
                value: _opponentScore,
                onChanged: (v) => setState(() => _opponentScore = v),
              ),
            ],
          ),

          const SizedBox(height: 32),

          PrimaryButton(
            text: 'Valider le score',
            isLoading: isLoading,
            onPressed: () async {
              await ref.read(challengeControllerProvider.notifier).reportResult(
                    challengeId: widget.challenge.id,
                    challengerScore: _challengerScore,
                    opponentScore: _opponentScore,
                  );

              final state = ref.read(challengeControllerProvider);
              if (context.mounted) {
                if (state.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error.toString()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Score enregistré !'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ScoreSelector extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _ScoreSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: AppColors.textSecondary,
            ),
            SizedBox(
              width: 40,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              onPressed: value < 20 ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}
