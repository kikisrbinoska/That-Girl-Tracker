import 'package:cloud_firestore/cloud_firestore.dart';

enum MealType { breakfast, lunch, dinner, snack }

class Meal {
  final String id;
  final String name;
  final MealType mealType;
  final String imageUrl;
  final DateTime time;
  final String notes;
  final String userId;

  const Meal({
    required this.id,
    required this.name,
    required this.mealType,
    this.imageUrl = '',
    required this.time,
    this.notes = '',
    required this.userId,
  });

  Meal copyWith({
    String? id,
    String? name,
    MealType? mealType,
    String? imageUrl,
    DateTime? time,
    String? notes,
    String? userId,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      imageUrl: imageUrl ?? this.imageUrl,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mealType': mealType.name,
      'imageUrl': imageUrl,
      'time': Timestamp.fromDate(time),
      'notes': notes,
      'userId': userId,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as String,
      name: map['name'] as String,
      mealType: MealType.values.firstWhere(
        (e) => e.name == map['mealType'],
        orElse: () => MealType.snack,
      ),
      imageUrl: map['imageUrl'] as String? ?? '',
      time: (map['time'] as Timestamp).toDate(),
      notes: map['notes'] as String? ?? '',
      userId: map['userId'] as String,
    );
  }

  static String typeLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  static const Map<MealType, int> typeColors = {
    MealType.breakfast: 0xFFF59E0B,
    MealType.lunch: 0xFF10B981,
    MealType.dinner: 0xFF3B82F6,
    MealType.snack: 0xFFEC4899,
  };
}
