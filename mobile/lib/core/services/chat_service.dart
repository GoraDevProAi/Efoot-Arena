import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Global community room
  static const String globalRoomId = 'global';

  CollectionReference _messages(String roomId) =>
      _firestore.collection('chat_rooms').doc(roomId).collection('messages');

  Stream<List<ChatMessageModel>> streamMessages({
    String roomId = globalRoomId,
    int limit = 80,
  }) {
    return _messages(roomId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatMessageModel.fromFirestore(d))
            .toList()
            .reversed
            .toList());
  }

  Future<void> sendMessage({
    required String senderId,
    required String senderUsername,
    required String text,
    bool isPremium = false,
    String roomId = globalRoomId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw Exception('Message vide');
    if (trimmed.length > 500) {
      throw Exception('Message trop long (max 500)');
    }

    await _messages(roomId).add({
      'senderId': senderId,
      'senderUsername': senderUsername,
      'text': trimmed,
      'isPremium': isPremium,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
