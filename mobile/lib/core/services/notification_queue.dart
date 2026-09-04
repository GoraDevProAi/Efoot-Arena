import 'package:cloud_firestore/cloud_firestore.dart';

/// Writes to `notification_queue` — a Cloud Function sends the actual FCM push.
/// This keeps secrets (FCM server key) off the client.
class NotificationQueue {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> enqueue({
    required String toUserId,
    required String title,
    required String body,
    String type = 'general',
    String? route,
    Map<String, String>? data,
  }) async {
    await _firestore.collection('notification_queue').add({
      'toUserId': toUserId,
      'title': title,
      'body': body,
      'type': type,
      'route': route,
      'data': data ?? {},
      'createdAt': FieldValue.serverTimestamp(),
      'sent': false,
    });
  }

  static Future<void> challengeReceived({
    required String toUserId,
    required String fromUsername,
  }) {
    return enqueue(
      toUserId: toUserId,
      title: 'Nouveau défi !',
      body: '$fromUsername t\'a défié. Accepte ou refuse.',
      type: 'challenge',
      route: '/challenges',
    );
  }

  static Future<void> challengeAccepted({
    required String toUserId,
    required String byUsername,
  }) {
    return enqueue(
      toUserId: toUserId,
      title: 'Défi accepté',
      body: '$byUsername a accepté ton défi. À vous de jouer !',
      type: 'challenge',
      route: '/challenges',
    );
  }

  static Future<void> challengeResult({
    required String toUserId,
    required String opponentUsername,
    required bool won,
  }) {
    return enqueue(
      toUserId: toUserId,
      title: won ? 'Victoire 🏆' : 'Défaite',
      body: won
          ? 'Tu as battu $opponentUsername !'
          : 'Tu as perdu contre $opponentUsername.',
      type: 'challenge',
      route: '/challenges',
    );
  }

  static Future<void> teamJoined({
    required String toUserId,
    required String username,
    required String teamName,
  }) {
    return enqueue(
      toUserId: toUserId,
      title: 'Nouveau membre',
      body: '$username a rejoint $teamName',
      type: 'team',
      route: '/teams',
    );
  }
}
