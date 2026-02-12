import 'package:cloud_firestore/cloud_firestore.dart';

class RoutineTask {
  final String id;
  final String text;
  final bool done;

  const RoutineTask({
    required this.id,
    required this.text,
    this.done = false,
  });

  RoutineTask copyWith({String? id, String? text, bool? done}) {
    return RoutineTask(
      id: id ?? this.id,
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'done': done};
  }

  factory RoutineTask.fromMap(Map<String, dynamic> map) {
    return RoutineTask(
      id: map['id'] as String,
      text: map['text'] as String,
      done: map['done'] as bool? ?? false,
    );
  }
}

class Routine {
  final String id; // "morning" or "evening"
  final List<RoutineTask> tasks;
  final DateTime date;
  final int? dayRating; // 1-5 stars, for evening
  final String userId;

  const Routine({
    required this.id,
    required this.tasks,
    required this.date,
    this.dayRating,
    required this.userId,
  });

  int get completedCount => tasks.where((t) => t.done).length;
  double get progress =>
      tasks.isEmpty ? 0 : completedCount / tasks.length;
  bool get allDone => tasks.every((t) => t.done);

  Routine copyWith({
    String? id,
    List<RoutineTask>? tasks,
    DateTime? date,
    int? dayRating,
    String? userId,
  }) {
    return Routine(
      id: id ?? this.id,
      tasks: tasks ?? this.tasks,
      date: date ?? this.date,
      dayRating: dayRating ?? this.dayRating,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'date': Timestamp.fromDate(date),
      'dayRating': dayRating,
      'userId': userId,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'] as String,
      tasks: (map['tasks'] as List<dynamic>?)
              ?.map((t) => RoutineTask.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      date: (map['date'] as Timestamp).toDate(),
      dayRating: map['dayRating'] as int?,
      userId: map['userId'] as String,
    );
  }

  static List<RoutineTask> defaultMorningTasks() {
    return const [
      RoutineTask(id: 'water', text: 'Drink water (500ml)'),
      RoutineTask(id: 'stretch', text: 'Stretch (5 minutes)'),
      RoutineTask(id: 'breakfast', text: 'Healthy breakfast'),
      RoutineTask(id: 'vitamins', text: 'Take vitamins'),
      RoutineTask(id: 'outfit', text: "Check today's outfit"),
    ];
  }

  static List<RoutineTask> defaultEveningTasks() {
    return const [
      RoutineTask(id: 'review', text: 'Review today (rate your day)'),
      RoutineTask(id: 'prep_outfit', text: "Prep tomorrow's outfit"),
      RoutineTask(id: 'alarm', text: 'Set alarm for tomorrow'),
      RoutineTask(id: 'skincare', text: 'Skincare routine'),
      RoutineTask(id: 'journal', text: 'Journal/gratitude'),
    ];
  }
}
