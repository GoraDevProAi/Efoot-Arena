import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class HighlightModel extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String? caption;
  final String mediaUrl;
  final String mediaType; // image | video_url
  final int likes;
  final DateTime createdAt;
  final bool isPremium;

  const HighlightModel({
    required this.id,
    required this.userId,
    required this.username,
    this.caption,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.likes = 0,
    required this.createdAt,
    this.isPremium = false,
  });

  factory HighlightModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HighlightModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Joueur',
      caption: data['caption'],
      mediaUrl: data['mediaUrl'] ?? '',
      mediaType: data['mediaType'] ?? 'image',
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPremium: data['isPremium'] == true,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, username, caption, mediaUrl, mediaType, likes, createdAt];
}
