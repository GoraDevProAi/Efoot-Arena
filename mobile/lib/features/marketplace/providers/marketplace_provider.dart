import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/marketplace_service.dart';
import '../../../shared/models/marketplace_listing_model.dart';
import '../../auth/providers/auth_provider.dart';

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService();
});

final marketplaceListingsProvider =
    StreamProvider<List<MarketplaceListingModel>>((ref) {
  return ref.watch(marketplaceServiceProvider).streamListings();
});

class MarketplaceController extends StateNotifier<AsyncValue<void>> {
  final MarketplaceService _service;
  final Ref _ref;

  MarketplaceController(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> create({
    required String title,
    required String description,
    required double price,
    String category = 'other',
  }) async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authStateProvider).valueOrNull;
      final user = _ref.read(currentUserProvider).valueOrNull;
      if (auth == null) throw Exception('Non connecté');

      await _service.createListing(
        sellerId: auth.uid,
        sellerUsername:
            user?.username.isNotEmpty == true ? user!.username : 'Vendeur',
        title: title,
        description: description,
        price: price,
        category: category,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deactivate(String listingId) async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authStateProvider).valueOrNull;
      if (auth == null) throw Exception('Non connecté');
      await _service.deactivateListing(listingId, auth.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final marketplaceControllerProvider =
    StateNotifierProvider<MarketplaceController, AsyncValue<void>>((ref) {
  return MarketplaceController(ref.watch(marketplaceServiceProvider), ref);
});
