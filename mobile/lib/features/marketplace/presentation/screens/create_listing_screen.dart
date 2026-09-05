import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/marketplace_provider.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String _category = 'other';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(
          _priceController.text.trim().replaceAll(' ', '').replaceAll(',', '.'),
        ) ??
        -1;

    await ref.read(marketplaceControllerProvider.notifier).create(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          price: price,
          category: _category,
        );

    final state = ref.read(marketplaceControllerProvider);
    if (!mounted) return;
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
          content: Text('Annonce publiée'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/marketplace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(marketplaceControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvelle annonce'),
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
                  controller: _titleController,
                  label: 'Titre',
                  hint: 'Ex: Coaching eFootball 1h',
                  validator: (v) =>
                      v == null || v.trim().length < 3 ? 'Titre requis' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descController,
                  label: 'Description',
                  hint: 'Détails de l\'offre...',
                  maxLines: 4,
                  validator: (v) => v == null || v.trim().length < 5
                      ? 'Description trop courte'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _priceController,
                  label: 'Prix (XOF)',
                  hint: '5000',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final p = double.tryParse(
                      (v ?? '').replaceAll(' ', '').replaceAll(',', '.'),
                    );
                    if (p == null || p < 0) return 'Prix invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Catégorie',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _category,
                  dropdownColor: AppColors.surfaceLight,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'account', child: Text('Compte')),
                    DropdownMenuItem(
                        value: 'coaching', child: Text('Coaching')),
                    DropdownMenuItem(value: 'other', child: Text('Autre')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pas de paiement in-app pour l\'instant. '
                  'Les acheteurs te contactent via le chat / en jeu.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  text: 'Publier l\'annonce',
                  onPressed: _submit,
                  isLoading: isLoading,
                  icon: Icons.storefront,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
