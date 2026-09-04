import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ranking_service.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

final rankingServiceProvider = Provider<RankingService>((ref) {
  return RankingService();
});

final globalRankingProvider = FutureProvider<List<UserModel>>((ref) {
  return ref.watch(rankingServiceProvider).getGlobalRanking();
});

final regionalRankingProvider = FutureProvider<List<UserModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || user.region.isEmpty) {
    return [];
  }
  return ref.watch(rankingServiceProvider).getRegionalRanking(
        region: user.region,
      );
});

final countryRankingProvider = FutureProvider<List<UserModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null || user.country.isEmpty) {
    return [];
  }
  return ref.watch(rankingServiceProvider).getCountryRanking(
        country: user.country,
      );
});
