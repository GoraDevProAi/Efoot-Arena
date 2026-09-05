import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/highlight_provider.dart';

class HighlightsScreen extends ConsumerWidget {
  const HighlightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(highlightsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Highlights'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/highlights/create'),
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Erreur: $e\n\nVérifie Storage + rules highlights.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_filter_outlined,
                      size: 56,
                      color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun highlight',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Publie ton premier moment fort',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/highlights/create'),
                    child: const Text('Publier'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(highlightsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final h = list[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.surfaceLight,
                              child: Text(
                                h.username.isNotEmpty
                                    ? h.username[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    h.username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: h.isPremium
                                          ? AppColors.gold
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (h.isPremium) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.workspace_premium,
                                        size: 14, color: AppColors.gold),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              DateFormat('dd/MM HH:mm').format(h.createdAt),
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      // Image
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Image.network(
                          h.mediaUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.surfaceLight,
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: AppColors.textMuted),
                            ),
                          ),
                        ),
                      ),
                      // Caption + likes
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (h.caption != null &&
                                h.caption!.isNotEmpty) ...[
                              Text(h.caption!,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 10),
                            ],
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => ref
                                      .read(highlightControllerProvider
                                          .notifier)
                                      .like(h.id),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.favorite_border,
                                          size: 20, color: AppColors.error),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${h.likes}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/highlights/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.movie_filter),
        label: const Text('Publier',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
