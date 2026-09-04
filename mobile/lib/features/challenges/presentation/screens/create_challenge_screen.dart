import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/challenge_provider.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() =>
      _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _searchController = TextEditingController();
  final _messageController = TextEditingController();
  List<UserModel> _results = [];
  UserModel? _selected;
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() => _searching = true);
    final results = await ref
        .read(challengeControllerProvider.notifier)
        .searchUsers(query);
    if (mounted) {
      setState(() {
        _results = results;
        _searching = false;
      });
    }
  }

  Future<void> _sendChallenge() async {
    if (_selected == null) return;

    await ref.read(challengeControllerProvider.notifier).createChallenge(
          opponentId: _selected!.uid,
          message: _messageController.text.trim().isEmpty
              ? null
              : _messageController.text.trim(),
        );

    final state = ref.read(challengeControllerProvider);
    if (mounted) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
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
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(challengeControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouveau défi'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _searchController,
                label: 'Chercher un joueur',
                hint: 'Nom d\'utilisateur...',
                prefixIcon: const Icon(Icons.search, size: 20),
                onChanged: _search,
              ),
              const SizedBox(height: 16),

              if (_searching)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_results.isNotEmpty && _selected == null)
                Expanded(
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final user = _results[index];
                      return ListTile(
                        onTap: () => setState(() => _selected = user),
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.surfaceLight,
                          child: Text(
                            user.username.isNotEmpty
                                ? user.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(
                          user.username,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${user.stats.rank} · ${user.country}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textMuted,
                        ),
                      );
                    },
                  ),
                )
              else if (_selected != null) ...[
                // Selected player
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          _selected!.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selected!.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${_selected!.stats.rank} · ${_selected!.stats.points} pts',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _selected = null),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _messageController,
                  label: 'Message (optionnel)',
                  hint: 'Ex: On se fait un match ?',
                  maxLines: 2,
                ),
                const Spacer(),
                PrimaryButton(
                  text: 'Envoyer le défi',
                  onPressed: _sendChallenge,
                  isLoading: isLoading,
                  icon: Icons.sports_esports,
                ),
              ] else if (_searchController.text.length >= 2 && !_searching)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Aucun joueur trouvé',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'Tape au moins 2 caractères pour chercher',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
