import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/premium_service.dart';
import '../../auth/providers/auth_provider.dart';

final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumService();
});

class PremiumController extends StateNotifier<AsyncValue<void>> {
  final PremiumService _service;
  final Ref _ref;

  PremiumController(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> activate({int days = 30}) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.activatePremium(user.uid, days: days);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deactivate() async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.deactivatePremium(user.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final premiumControllerProvider =
    StateNotifierProvider<PremiumController, AsyncValue<void>>((ref) {
  return PremiumController(ref.watch(premiumServiceProvider), ref);
});
