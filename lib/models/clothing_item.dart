import 'package:cloud_firestore/cloud_firestore.dart';

enum ClothingCategory { casual, formal, sport, lounge, outerwear, accessories }

enum Season { spring, summer, fall, winter, allSeasons }

class ClothingItem {
  final String id;
  final String name;
  final ClothingCategory category;
  final String color;
  final Season season;
  final String imageUrl;
  final List<String> tags;
  final bool isFavorite;
  final String userId;
  final DateTime createdAt;

  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    this.color = '',
    this.season = Season.allSeasons,
    this.imageUrl = '',
    this.tags = const [],
    this.isFavorite = false,
    required this.userId,
    required this.createdAt,
  });

  ClothingItem copyWith({
    String? id,
    String? name,
    ClothingCategory? category,
    String? color,
    Season? season,
    String? imageUrl,
    List<String>? tags,
    bool? isFavorite,
    String? userId,
    DateTime? createdAt,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      season: season ?? this.season,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'color': color,
      'season': season.name,
      'imageUrl': imageUrl,
      'tags': tags,
      'isFavorite': isFavorite,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: ClothingCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ClothingCategory.casual,
      ),
      color: map['color'] as String? ?? '',
      season: Season.values.firstWhere(
        (e) => e.name == map['season'],
        orElse: () => Season.allSeasons,
      ),
      imageUrl: map['imageUrl'] as String? ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      isFavorite: map['isFavorite'] as bool? ?? false,
      userId: map['userId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  static String categoryLabel(ClothingCategory cat) {
    switch (cat) {
      case ClothingCategory.casual:
        return 'Casual';
      case ClothingCategory.formal:
        return 'Formal';
      case ClothingCategory.sport:
        return 'Sport';
      case ClothingCategory.lounge:
        return 'Lounge';
      case ClothingCategory.outerwear:
        return 'Outerwear';
      case ClothingCategory.accessories:
        return 'Accessories';
    }
  }

  static String seasonLabel(Season s) {
    switch (s) {
      case Season.spring:
        return 'Spring';
      case Season.summer:
        return 'Summer';
      case Season.fall:
        return 'Fall';
      case Season.winter:
        return 'Winter';
      case Season.allSeasons:
        return 'All Seasons';
    }
  }

  static const Map<ClothingCategory, int> categoryColors = {
    ClothingCategory.casual: 0xFFEC4899,
    ClothingCategory.formal: 0xFF1F2937,
    ClothingCategory.sport: 0xFF10B981,
    ClothingCategory.lounge: 0xFFF59E0B,
    ClothingCategory.outerwear: 0xFF3B82F6,
    ClothingCategory.accessories: 0xFF8B5CF6,
  };
}
