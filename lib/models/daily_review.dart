import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReview {
  final String dateKey;
  final int rating;
  final int steps;
  final int waterMl;
  final String moodNotes;
  final DateTime date;
  final String userId;

  const DailyReview({
    required this.dateKey,
    required this.rating,
    required this.steps,
    required this.waterMl,
    required this.moodNotes,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'steps': steps,
      'waterMl': waterMl,
      'moodNotes': moodNotes,
      'date': Timestamp.fromDate(date),
      'userId': userId,
    };
  }

  factory DailyReview.fromMap(String dateKey, Map<String, dynamic> map) {
    return DailyReview(
      dateKey: dateKey,
      rating: map['rating'] as int? ?? 0,
      steps: map['steps'] as int? ?? 0,
      waterMl: map['waterMl'] as int? ?? 0,
      moodNotes: map['moodNotes'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: map['userId'] as String? ?? '',
    );
  }

  DailyReview copyWith({
    int? rating,
    int? steps,
    int? waterMl,
    String? moodNotes,
  }) {
    return DailyReview(
      dateKey: dateKey,
      rating: rating ?? this.rating,
      steps: steps ?? this.steps,
      waterMl: waterMl ?? this.waterMl,
      moodNotes: moodNotes ?? this.moodNotes,
      date: date,
      userId: userId,
    );
  }
}
