import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/profile_service.dart';
import '../../auth/providers/auth_provider.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileService _service;
  final Ref _ref;

  ProfileController(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? country,
    String? region,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');

      await _service.updateProfile(
        uid: user.uid,
        displayName: displayName,
        bio: bio,
        country: country,
        region: region,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> uploadAvatar(File file) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.uploadAvatar(uid: user.uid, file: file);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeAvatar() async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Non connecté');
      await _service.removeAvatar(user.uid);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(ref.watch(profileServiceProvider), ref);
});
