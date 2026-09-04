import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../constants/app_constants.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _users =>
      _firestore.collection(AppConstants.usersCollection);

  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? bio,
    String? country,
    String? region,
  }) async {
    final updates = <String, dynamic>{
      'lastActive': FieldValue.serverTimestamp(),
    };

    if (displayName != null) {
      final name = displayName.trim();
      if (name.length < AppConstants.minUsernameLength ||
          name.length > AppConstants.maxUsernameLength) {
        throw Exception(
          'Le pseudo doit faire entre ${AppConstants.minUsernameLength} et ${AppConstants.maxUsernameLength} caractères',
        );
      }
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name)) {
        throw Exception('Lettres, chiffres et _ uniquement');
      }

      // Check username uniqueness (if changed)
      final current = await _users.doc(uid).get();
      final currentUsername =
          (current.data() as Map<String, dynamic>?)?['username'] as String? ??
              '';
      if (name.toLowerCase() != currentUsername.toLowerCase()) {
        final taken = await _users
            .where('username', isEqualTo: name.toLowerCase())
            .limit(1)
            .get();
        if (taken.docs.isNotEmpty) {
          throw Exception('Ce nom d\'utilisateur est déjà pris');
        }
        updates['username'] = name.toLowerCase();
        updates['displayName'] = name;
      }
    }

    if (bio != null) {
      final b = bio.trim();
      if (b.length > 150) {
        throw Exception('Bio max 150 caractères');
      }
      updates['bio'] = b;
    }
    if (country != null) updates['country'] = country;
    if (region != null) updates['region'] = region;

    await _users.doc(uid).update(updates);
  }

  Future<String> uploadAvatar({
    required String uid,
    required File file,
  }) async {
    final ref = _storage.ref().child('avatars/$uid.jpg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    await ref.putFile(file, metadata);
    final url = await ref.getDownloadURL();
    await _users.doc(uid).update({
      'avatarUrl': url,
      'lastActive': FieldValue.serverTimestamp(),
    });
    return url;
  }

  Future<void> removeAvatar(String uid) async {
    try {
      await _storage.ref().child('avatars/$uid.jpg').delete();
    } catch (_) {}
    await _users.doc(uid).update({
      'avatarUrl': null,
      'lastActive': FieldValue.serverTimestamp(),
    });
  }
}
