import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/team_provider.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isOpen = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final id = await ref.read(teamControllerProvider.notifier).createTeam(
          name: _nameController.text.trim(),
          country: user.country,
          region: user.region,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          isOpen: _isOpen,
        );

    final state = ref.read(teamControllerProvider);
    if (mounted) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (id != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Équipe créée !'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/teams');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(teamControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer une équipe'),
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
                  label: 'Nom de l\'équipe',
                  hint: 'Ex: Lions FC',
                  prefixIcon: const Icon(Icons.shield_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nom requis';
                    if (v.trim().length < AppConstants.minTeamNameLength) {
                      return 'Minimum ${AppConstants.minTeamNameLength} caractères';
                    }
                    if (v.trim().length > AppConstants.maxTeamNameLength) {
                      return 'Maximum ${AppConstants.maxTeamNameLength} caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _descController,
                  label: 'Description (optionnel)',
                  hint: 'Présente ton équipe...',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Équipe ouverte',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'N\'importe qui peut rejoindre',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isOpen,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _isOpen = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                PrimaryButton(
                  text: 'Créer l\'équipe',
                  onPressed: _create,
                  isLoading: isLoading,
                  icon: Icons.groups,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
