import 'package:cloud_firestore/cloud_firestore.dart';

class SleepLog {
  final DateTime date;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int durationMinutes;
  final String userId;

  const SleepLog({
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.durationMinutes,
    required this.userId,
  });

  String get durationText {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return '${hours}h ${mins}m';
  }

  bool get meetsGoal => durationMinutes >= 480; // 8 hours

  SleepLog copyWith({
    DateTime? date,
    DateTime? bedtime,
    DateTime? wakeTime,
    int? durationMinutes,
    String? userId,
  }) {
    return SleepLog(
      date: date ?? this.date,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'bedtime': Timestamp.fromDate(bedtime),
      'wakeTime': Timestamp.fromDate(wakeTime),
      'durationMinutes': durationMinutes,
      'userId': userId,
    };
  }

  factory SleepLog.fromMap(Map<String, dynamic> map) {
    return SleepLog(
      date: (map['date'] as Timestamp).toDate(),
      bedtime: (map['bedtime'] as Timestamp).toDate(),
      wakeTime: (map['wakeTime'] as Timestamp).toDate(),
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      userId: map['userId'] as String,
    );
  }
}
