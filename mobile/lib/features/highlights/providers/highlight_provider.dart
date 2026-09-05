import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/highlight_service.dart';
import '../../../shared/models/highlight_model.dart';
import '../../auth/providers/auth_provider.dart';

final highlightServiceProvider = Provider<HighlightService>((ref) {
  return HighlightService();
});

final highlightsProvider = StreamProvider<List<HighlightModel>>((ref) {
  return ref.watch(highlightServiceProvider).streamHighlights();
});

class HighlightController extends StateNotifier<AsyncValue<void>> {
  final HighlightService _service;
  final Ref _ref;

  HighlightController(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> publish({
    required File image,
    String? caption,
  }) async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authStateProvider).valueOrNull;
      final user = _ref.read(currentUserProvider).valueOrNull;
      if (auth == null) throw Exception('Non connecté');

      await _service.createHighlight(
        userId: auth.uid,
        username: user?.username.isNotEmpty == true
            ? user!.username
            : 'Joueur',
        imageFile: image,
        caption: caption,
        isPremium: user?.isPremium ?? false,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> like(String id) async {
    try {
      await _service.likeHighlight(id);
    } catch (_) {}
  }
}

final highlightControllerProvider =
    StateNotifierProvider<HighlightController, AsyncValue<void>>((ref) {
  return HighlightController(ref.watch(highlightServiceProvider), ref);
});
