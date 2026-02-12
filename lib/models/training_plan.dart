import 'workout.dart';

class TrainingPlan {
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final WorkoutType workoutType;
  final int duration;
  final String notes;
  final String userId;

  const TrainingPlan({
    required this.dayOfWeek,
    required this.workoutType,
    required this.duration,
    this.notes = '',
    required this.userId,
  });

  bool get isRestDay => duration == 0;

  TrainingPlan copyWith({
    int? dayOfWeek,
    WorkoutType? workoutType,
    int? duration,
    String? notes,
    String? userId,
  }) {
    return TrainingPlan(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      workoutType: workoutType ?? this.workoutType,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayOfWeek': dayOfWeek,
      'workoutType': workoutType.name,
      'duration': duration,
      'notes': notes,
      'userId': userId,
    };
  }

  factory TrainingPlan.fromMap(Map<String, dynamic> map) {
    return TrainingPlan(
      dayOfWeek: map['dayOfWeek'] as int,
      workoutType: WorkoutType.values.firstWhere(
        (e) => e.name == map['workoutType'],
        orElse: () => WorkoutType.other,
      ),
      duration: map['duration'] as int? ?? 0,
      notes: map['notes'] as String? ?? '',
      userId: map['userId'] as String,
    );
  }

  static String dayName(int day) {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  static String dayShort(int day) {
    switch (day) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}
