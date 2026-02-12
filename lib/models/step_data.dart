import 'package:cloud_firestore/cloud_firestore.dart';

class StepData {
  final DateTime date;
  final int stepCount;
  final int goal;
  final DateTime lastUpdated;
  final String userId;

  const StepData({
    required this.date,
    required this.stepCount,
    this.goal = 10000,
    required this.lastUpdated,
    required this.userId,
  });

  double get progress => (stepCount / goal).clamp(0.0, 1.0);
  double get distanceKm => stepCount * 0.000762;
  int get caloriesBurned => (stepCount * 0.04).round();

  StepData copyWith({
    DateTime? date,
    int? stepCount,
    int? goal,
    DateTime? lastUpdated,
    String? userId,
  }) {
    return StepData(
      date: date ?? this.date,
      stepCount: stepCount ?? this.stepCount,
      goal: goal ?? this.goal,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'stepCount': stepCount,
      'goal': goal,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'userId': userId,
    };
  }

  factory StepData.fromMap(Map<String, dynamic> map) {
    return StepData(
      date: (map['date'] as Timestamp).toDate(),
      stepCount: map['stepCount'] as int? ?? 0,
      goal: map['goal'] as int? ?? 10000,
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
      userId: map['userId'] as String,
    );
  }
}
