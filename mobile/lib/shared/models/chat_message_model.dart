import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatMessageModel extends Equatable {
  final String id;
  final String senderId;
  final String senderUsername;
  final String text;
  final DateTime createdAt;
  final bool isPremium;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    required this.text,
    required this.createdAt,
    this.isPremium = false,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderUsername: data['senderUsername'] ?? 'Joueur',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPremium: data['isPremium'] == true,
    );
  }

  @override
  List<Object?> get props =>
      [id, senderId, senderUsername, text, createdAt, isPremium];
}
