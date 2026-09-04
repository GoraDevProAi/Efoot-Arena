import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _country;
  String? _region;
  File? _pickedImage;
  bool _initialized = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _initFromUser() {
    if (_initialized) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    _usernameController = TextEditingController(text: user.username);
    _bioController = TextEditingController(text: user.bio ?? '');
    _country = user.country.isNotEmpty ? user.country : null;
    _region = user.region.isNotEmpty ? user.region : null;
    _initialized = true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (xfile != null) {
      setState(() => _pickedImage = File(xfile.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(profileControllerProvider.notifier);

    if (_pickedImage != null) {
      await controller.uploadAvatar(_pickedImage!);
      final s = ref.read(profileControllerProvider);
      if (s.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    await controller.updateProfile(
      displayName: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      country: _country,
      region: _region,
    );

    final state = ref.read(profileControllerProvider);
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
            content: Text('Profil mis à jour'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final isLoading = ref.watch(profileControllerProvider).isLoading;

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Non connecté')));
        }
        _initFromUser();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Modifier le profil'),
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
                  children: [
                    // Avatar
                    GestureDetector(
                      onTap: isLoading ? null : _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: AppColors.surfaceLight,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (user.avatarUrl != null
                                    ? NetworkImage(user.avatarUrl!)
                                        as ImageProvider
                                    : null),
                            child: _pickedImage == null &&
                                    user.avatarUrl == null
                                ? Text(
                                    user.username.isNotEmpty
                                        ? user.username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Appuie pour changer la photo',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 28),

                    AppTextField(
                      controller: _usernameController,
                      label: 'Nom d\'utilisateur',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requis';
                        }
                        if (v.trim().length <
                            AppConstants.minUsernameLength) {
                          return 'Trop court';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                          return 'Lettres, chiffres et _ uniquement';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    AppTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Parle de toi en quelques mots...',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pays',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _country != null &&
                              AppConstants.africanCountries.contains(_country)
                          ? _country
                          : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.public, size: 20),
                      ),
                      dropdownColor: AppColors.surfaceLight,
                      items: AppConstants.africanCountries
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _country = v),
                    ),

                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Région',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _region != null &&
                              AppConstants.regions.contains(_region)
                          ? _region
                          : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.map_outlined, size: 20),
                      ),
                      dropdownColor: AppColors.surfaceLight,
                      items: AppConstants.regions
                          .map((r) =>
                              DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) => setState(() => _region = v),
                    ),

                    const SizedBox(height: 36),

                    PrimaryButton(
                      text: 'Enregistrer',
                      onPressed: _save,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
