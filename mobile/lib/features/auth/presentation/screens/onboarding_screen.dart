import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  String? _selectedCountry;
  String? _selectedRegion;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null || _selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionne ton pays et ta région'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).completeOnboarding(
          username: _usernameController.text.trim(),
          country: _selectedCountry!,
          region: _selectedRegion!,
        );

    final state = ref.read(authControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'eF',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Finalise ton profil',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choisis ton pseudo et ta région pour commencer à compétir',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),

                const SizedBox(height: 36),

                AppTextField(
                  controller: _usernameController,
                  label: 'Nom d\'utilisateur',
                  hint: 'ex: KingMessi',
                  textCapitalization: TextCapitalization.none,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nom d\'utilisateur requis';
                    }
                    if (value.length < AppConstants.minUsernameLength) {
                      return 'Minimum ${AppConstants.minUsernameLength} caractères';
                    }
                    if (value.length > AppConstants.maxUsernameLength) {
                      return 'Maximum ${AppConstants.maxUsernameLength} caractères';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'Lettres, chiffres et _ uniquement';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Pays',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: const InputDecoration(
                    hintText: 'Sélectionne ton pays',
                    prefixIcon: Icon(Icons.public, size: 20),
                  ),
                  dropdownColor: AppColors.surfaceLight,
                  items: AppConstants.africanCountries
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCountry = value);
                  },
                  validator: (value) => value == null ? 'Pays requis' : null,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Région',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(
                    hintText: 'Sélectionne ta région',
                    prefixIcon: Icon(Icons.map_outlined, size: 20),
                  ),
                  dropdownColor: AppColors.surfaceLight,
                  items: AppConstants.regions
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedRegion = value);
                  },
                  validator: (value) => value == null ? 'Région requise' : null,
                ),

                const SizedBox(height: 40),

                PrimaryButton(
                  text: 'Commencer à compétir',
                  onPressed: _complete,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
