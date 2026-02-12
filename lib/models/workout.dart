import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkoutType { legs, upper, cardio, yoga, pilates, hiit, outdoor, other }

class Workout {
  final String id;
  final WorkoutType type;
  final int duration;
  final int caloriesBurned;
  final int? sets;
  final int? reps;
  final String notes;
  final DateTime date;
  final String userId;

  const Workout({
    required this.id,
    required this.type,
    required this.duration,
    required this.caloriesBurned,
    this.sets,
    this.reps,
    this.notes = '',
    required this.date,
    required this.userId,
  });

  Workout copyWith({
    String? id,
    WorkoutType? type,
    int? duration,
    int? caloriesBurned,
    int? sets,
    int? reps,
    String? notes,
    DateTime? date,
    String? userId,
  }) {
    return Workout(
      id: id ?? this.id,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'sets': sets,
      'reps': reps,
      'notes': notes,
      'date': Timestamp.fromDate(date),
      'userId': userId,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as String,
      type: WorkoutType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => WorkoutType.other,
      ),
      duration: map['duration'] as int? ?? 0,
      caloriesBurned: map['caloriesBurned'] as int? ?? 0,
      sets: map['sets'] as int?,
      reps: map['reps'] as int?,
      notes: map['notes'] as String? ?? '',
      date: (map['date'] as Timestamp).toDate(),
      userId: map['userId'] as String,
    );
  }

  static String typeLabel(WorkoutType type) {
    switch (type) {
      case WorkoutType.legs:
        return 'Legs';
      case WorkoutType.upper:
        return 'Upper Body';
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.yoga:
        return 'Yoga';
      case WorkoutType.pilates:
        return 'Pilates';
      case WorkoutType.hiit:
        return 'HIIT';
      case WorkoutType.outdoor:
        return 'Outdoor';
      case WorkoutType.other:
        return 'Other';
    }
  }

  static const Map<WorkoutType, int> typeColors = {
    WorkoutType.legs: 0xFFEC4899,
    WorkoutType.upper: 0xFF3B82F6,
    WorkoutType.cardio: 0xFF10B981,
    WorkoutType.yoga: 0xFF8B5CF6,
    WorkoutType.pilates: 0xFFF59E0B,
    WorkoutType.hiit: 0xFFEF4444,
    WorkoutType.outdoor: 0xFF06B6D4,
    WorkoutType.other: 0xFF9CA3AF,
  };
}
