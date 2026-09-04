import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedCountry;
  String? _selectedRegion;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
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

    await ref.read(authControllerProvider.notifier).registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Rejoins eFoot Arena',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Crée ton profil compétitif en quelques secondes',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),

                const SizedBox(height: 32),

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

                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'ton@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email requis';
                    if (!value.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                AppTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  hint: 'Minimum 6 caractères',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mot de passe requis';
                    }
                    if (value.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmer le mot de passe',
                  hint: 'Retape ton mot de passe',
                  obscureText: _obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Country dropdown
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
                  validator: (value) =>
                      value == null ? 'Pays requis' : null,
                ),

                const SizedBox(height: 20),

                // Region dropdown
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
                  validator: (value) =>
                      value == null ? 'Région requise' : null,
                ),

                const SizedBox(height: 36),

                PrimaryButton(
                  text: 'Créer mon compte',
                  onPressed: _register,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Déjà un compte ? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: isLoading ? null : () => context.go('/login'),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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
