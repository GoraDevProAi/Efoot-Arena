import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../providers/highlight_provider.dart';

class CreateHighlightScreen extends ConsumerStatefulWidget {
  const CreateHighlightScreen({super.key});

  @override
  ConsumerState<CreateHighlightScreen> createState() =>
      _CreateHighlightScreenState();
}

class _CreateHighlightScreenState
    extends ConsumerState<CreateHighlightScreen> {
  final _captionController = TextEditingController();
  File? _image;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (x != null) setState(() => _image = File(x.path));
  }

  Future<void> _publish() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisis une image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await ref.read(highlightControllerProvider.notifier).publish(
          image: _image!,
          caption: _captionController.text.trim().isEmpty
              ? null
              : _captionController.text.trim(),
        );

    final state = ref.read(highlightControllerProvider);
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
          content: Text('Highlight publié !'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/highlights');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(highlightControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouveau highlight'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: isLoading ? null : _pick,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _image == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'Choisir une image / screenshot',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _captionController,
                label: 'Légende (optionnel)',
                hint: 'Ex: Quel golazo en finale 🔥',
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: 'Publier',
                onPressed: _publish,
                isLoading: isLoading,
                icon: Icons.movie_filter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
