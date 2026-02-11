import 'package:cloud_firestore/cloud_firestore.dart';

class Outfit {
  final String id;
  final String name;
  final List<String> items;
  final bool isFavorite;
  final List<String> usedForEvents;
  final DateTime? lastWorn;
  final String userId;
  final DateTime createdAt;

  const Outfit({
    required this.id,
    required this.name,
    this.items = const [],
    this.isFavorite = false,
    this.usedForEvents = const [],
    this.lastWorn,
    required this.userId,
    required this.createdAt,
  });

  Outfit copyWith({
    String? id,
    String? name,
    List<String>? items,
    bool? isFavorite,
    List<String>? usedForEvents,
    DateTime? lastWorn,
    String? userId,
    DateTime? createdAt,
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      isFavorite: isFavorite ?? this.isFavorite,
      usedForEvents: usedForEvents ?? this.usedForEvents,
      lastWorn: lastWorn ?? this.lastWorn,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'items': items,
      'isFavorite': isFavorite,
      'usedForEvents': usedForEvents,
      'lastWorn': lastWorn != null ? Timestamp.fromDate(lastWorn!) : null,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'] as String,
      name: map['name'] as String,
      items: List<String>.from(map['items'] ?? []),
      isFavorite: map['isFavorite'] as bool? ?? false,
      usedForEvents: List<String>.from(map['usedForEvents'] ?? []),
      lastWorn: map['lastWorn'] != null
          ? (map['lastWorn'] as Timestamp).toDate()
          : null,
      userId: map['userId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
