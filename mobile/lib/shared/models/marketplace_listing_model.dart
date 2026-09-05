import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MarketplaceListingModel extends Equatable {
  final String id;
  final String sellerId;
  final String sellerUsername;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String category; // account, coaching, other
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  const MarketplaceListingModel({
    required this.id,
    required this.sellerId,
    required this.sellerUsername,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'XOF',
    this.category = 'other',
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory MarketplaceListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketplaceListingModel(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      sellerUsername: data['sellerUsername'] ?? 'Vendeur',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'XOF',
      category: data['category'] ?? 'other',
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, sellerId, title, price, category, isActive, createdAt];
}
