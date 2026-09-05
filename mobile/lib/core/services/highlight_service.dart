import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../shared/models/highlight_model.dart';

class HighlightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _highlights =>
      _firestore.collection('highlights');

  Stream<List<HighlightModel>> streamHighlights({int limit = 40}) {
    return _highlights
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => HighlightModel.fromFirestore(d)).toList());
  }

  Future<String> createHighlight({
    required String userId,
    required String username,
    required File imageFile,
    String? caption,
    bool isPremium = false,
  }) async {
    final id = const Uuid().v4();
    final ref = _storage.ref().child('highlights/$userId/$id.jpg');
    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await ref.getDownloadURL();

    await _highlights.doc(id).set({
      'userId': userId,
      'username': username,
      'caption': caption?.trim(),
      'mediaUrl': url,
      'mediaType': 'image',
      'likes': 0,
      'isPremium': isPremium,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return id;
  }

  Future<void> likeHighlight(String highlightId) async {
    await _highlights.doc(highlightId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> deleteHighlight(String highlightId, String userId) async {
    final doc = await _highlights.doc(highlightId).get();
    if (!doc.exists) throw Exception('Highlight introuvable');
    final data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != userId) throw Exception('Non autorisé');
    await _highlights.doc(highlightId).delete();
  }
}
