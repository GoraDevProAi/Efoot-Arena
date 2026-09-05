import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

/// MVP Premium without real payments.
/// Later: replace activatePremium with Play Billing / RevenueCat.
class PremiumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users =>
      _firestore.collection(AppConstants.usersCollection);

  Future<void> activatePremium(String uid, {int days = 30}) async {
    final expiresAt = DateTime.now().add(Duration(days: days));
    await _users.doc(uid).update({
      'isPremium': true,
      'premiumExpiresAt': Timestamp.fromDate(expiresAt),
      'premiumUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deactivatePremium(String uid) async {
    await _users.doc(uid).update({
      'isPremium': false,
      'premiumExpiresAt': null,
      'premiumUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Check and auto-expire if needed
  Future<bool> refreshPremiumStatus(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    final isPremium = data['isPremium'] == true;
    final expires = data['premiumExpiresAt'] as Timestamp?;
    if (isPremium && expires != null && expires.toDate().isBefore(DateTime.now())) {
      await deactivatePremium(uid);
      return false;
    }
    return isPremium;
  }
}
