import 'package:cloud_firestore/cloud_firestore.dart';

class WaterEntry {
  final DateTime time;
  final int amountMl;

  const WaterEntry({required this.time, required this.amountMl});

  Map<String, dynamic> toMap() {
    return {
      'time': Timestamp.fromDate(time),
      'amountMl': amountMl,
    };
  }

  factory WaterEntry.fromMap(Map<String, dynamic> map) {
    return WaterEntry(
      time: (map['time'] as Timestamp).toDate(),
      amountMl: map['amountMl'] as int? ?? 0,
    );
  }
}

class WaterLog {
  final DateTime date;
  final int goalMl;
  final List<WaterEntry> entries;
  final String userId;

  const WaterLog({
    required this.date,
    this.goalMl = 2500,
    this.entries = const [],
    required this.userId,
  });

  int get totalMl => entries.fold(0, (total, e) => total + e.amountMl);
  double get progress => (totalMl / goalMl).clamp(0.0, 1.0);

  WaterLog copyWith({
    DateTime? date,
    int? goalMl,
    List<WaterEntry>? entries,
    String? userId,
  }) {
    return WaterLog(
      date: date ?? this.date,
      goalMl: goalMl ?? this.goalMl,
      entries: entries ?? this.entries,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'goalMl': goalMl,
      'entries': entries.map((e) => e.toMap()).toList(),
      'totalMl': totalMl,
      'userId': userId,
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      date: (map['date'] as Timestamp).toDate(),
      goalMl: map['goalMl'] as int? ?? 2500,
      entries: (map['entries'] as List<dynamic>?)
              ?.map((e) => WaterEntry.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      userId: map['userId'] as String,
    );
  }
}
