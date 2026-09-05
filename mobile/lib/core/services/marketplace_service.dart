import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/marketplace_listing_model.dart';

class MarketplaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _listings =>
      _firestore.collection('marketplace_listings');

  Stream<List<MarketplaceListingModel>> streamListings({int limit = 50}) {
    return _listings
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MarketplaceListingModel.fromFirestore(d))
            .toList());
  }

  Future<String> createListing({
    required String sellerId,
    required String sellerUsername,
    required String title,
    required String description,
    required double price,
    String currency = 'XOF',
    String category = 'other',
    String? imageUrl,
  }) async {
    final t = title.trim();
    final d = description.trim();
    if (t.length < 3) throw Exception('Titre trop court');
    if (d.length < 5) throw Exception('Description trop courte');
    if (price < 0) throw Exception('Prix invalide');

    final doc = await _listings.add({
      'sellerId': sellerId,
      'sellerUsername': sellerUsername,
      'title': t,
      'description': d,
      'price': price,
      'currency': currency,
      'category': category,
      'imageUrl': imageUrl,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> deactivateListing(String listingId, String userId) async {
    final doc = await _listings.doc(listingId).get();
    if (!doc.exists) throw Exception('Annonce introuvable');
    final data = doc.data() as Map<String, dynamic>;
    if (data['sellerId'] != userId) throw Exception('Non autorisé');
    await _listings.doc(listingId).update({'isActive': false});
  }
}
