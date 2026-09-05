import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/chat_service.dart';
import '../../../shared/models/chat_message_model.dart';
import '../../auth/providers/auth_provider.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final chatMessagesProvider = StreamProvider<List<ChatMessageModel>>((ref) {
  return ref.watch(chatServiceProvider).streamMessages();
});

class ChatController extends StateNotifier<AsyncValue<void>> {
  final ChatService _service;
  final Ref _ref;

  ChatController(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> send(String text) async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authStateProvider).valueOrNull;
      final user = _ref.read(currentUserProvider).valueOrNull;
      if (auth == null) throw Exception('Non connecté');

      await _service.sendMessage(
        senderId: auth.uid,
        senderUsername: user?.username.isNotEmpty == true
            ? user!.username
            : (auth.displayName ?? 'Joueur'),
        text: text,
        isPremium: user?.isPremium ?? false,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, AsyncValue<void>>((ref) {
  return ChatController(ref.watch(chatServiceProvider), ref);
});
