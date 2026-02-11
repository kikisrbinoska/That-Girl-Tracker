import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  final String id;
  final String name;
  final String brand;
  final double? price;
  final String link;
  final String imageUrl;
  final bool isPurchased;
  final String userId;
  final DateTime createdAt;

  const WishlistItem({
    required this.id,
    required this.name,
    this.brand = '',
    this.price,
    this.link = '',
    this.imageUrl = '',
    this.isPurchased = false,
    required this.userId,
    required this.createdAt,
  });

  WishlistItem copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    String? link,
    String? imageUrl,
    bool? isPurchased,
    String? userId,
    DateTime? createdAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      link: link ?? this.link,
      imageUrl: imageUrl ?? this.imageUrl,
      isPurchased: isPurchased ?? this.isPurchased,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'link': link,
      'imageUrl': imageUrl,
      'isPurchased': isPurchased,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble(),
      link: map['link'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      isPurchased: map['isPurchased'] as bool? ?? false,
      userId: map['userId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
