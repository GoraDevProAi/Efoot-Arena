import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/tournament_provider.dart';

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() =>
      _CreateTournamentScreenState();
}

class _CreateTournamentScreenState
    extends ConsumerState<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  int _maxPlayers = 8;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final id = await ref.read(tournamentControllerProvider.notifier).create(
          name: _nameController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          maxPlayers: _maxPlayers,
        );

    final state = ref.read(tournamentControllerProvider);
    if (!mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (id != null) {
      context.go('/tournaments/$id');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(tournamentControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouveau tournoi'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Nom du tournoi',
                  hint: 'Ex: Coupe Dakar Open',
                  prefixIcon: const Icon(Icons.emoji_events_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().length < 3) {
                      return 'Minimum 3 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _descController,
                  label: 'Description (optionnel)',
                  hint: 'Règles, horaires...',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Nombre max de joueurs',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _maxPlayers > 2
                            ? () => setState(() => _maxPlayers--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Expanded(
                        child: Text(
                          '$_maxPlayers',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _maxPlayers < 32
                            ? () => setState(() => _maxPlayers++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                PrimaryButton(
                  text: 'Créer le tournoi',
                  onPressed: _submit,
                  isLoading: isLoading,
                  icon: Icons.emoji_events,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
