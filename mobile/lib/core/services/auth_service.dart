import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../shared/models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Sign in with Email & Password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _updateLastActive(credential.user!.uid);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with Email & Password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required String country,
    required String region,
  }) async {
    try {
      // Check if username is already taken
      final usernameExists = await _isUsernameTaken(username);
      if (usernameExists) {
        throw Exception('Ce nom d\'utilisateur est déjà pris');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;
      final now = DateTime.now();

      // Create user document in Firestore
      final newUser = UserModel(
        uid: user.uid,
        username: username.trim().toLowerCase(),
        email: email.trim(),
        displayName: username.trim(),
        country: country,
        region: region,
        createdAt: now,
        lastActive: now,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(newUser.toFirestore());

      // Update display name in Firebase Auth
      await user.updateDisplayName(username.trim());

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Connexion Google annulée');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user document exists
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // First time Google sign-in → create profile (incomplete)
        final now = DateTime.now();
        final newUser = UserModel(
          uid: user.uid,
          username: '', // Will be set in onboarding
          email: user.email ?? '',
          displayName: user.displayName,
          avatarUrl: user.photoURL,
          country: '',
          region: '',
          createdAt: now,
          lastActive: now,
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(newUser.toFirestore());
      } else {
        await _updateLastActive(user.uid);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Complete Google profile (after first login)
  Future<void> completeGoogleProfile({
    required String username,
    required String country,
    required String region,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Aucun utilisateur connecté');

    final usernameExists = await _isUsernameTaken(username);
    if (usernameExists) {
      throw Exception('Ce nom d\'utilisateur est déjà pris');
    }

    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).update({
      'username': username.trim().toLowerCase(),
      'displayName': username.trim(),
      'country': country,
      'region': region,
    });

    await user.updateDisplayName(username.trim());
  }

  // Sign out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Stream user data
  Stream<UserModel?> streamUserData(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Check username availability
  Future<bool> _isUsernameTaken(String username) async {
    final query = await _firestore
        .collection(AppConstants.usersCollection)
        .where('username', isEqualTo: username.trim().toLowerCase())
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> _updateLastActive(String uid) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'lastActive': Timestamp.now(),
      'isOnline': true,
    });
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Email invalide';
      case 'weak-password':
        return 'Le mot de passe est trop faible (min. 6 caractères)';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessaie plus tard';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifie ta connexion';
      default:
        return e.message ?? 'Une erreur est survenue';
    }
  }
}
