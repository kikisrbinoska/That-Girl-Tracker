import 'package:cloud_firestore/cloud_firestore.dart';

enum EventType { work, gym, social, personal, appointment }

enum RecurringType { none, daily, weekly }

class Event {
  final String id;
  final String title;
  final EventType type;
  final DateTime dateTime;
  final String notes;
  final String? outfitSuggestion;
  final bool isRecurring;
  final RecurringType recurringType;
  final bool notificationEnabled;
  final int? notificationId;
  final String userId;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    this.notes = '',
    this.outfitSuggestion,
    this.isRecurring = false,
    this.recurringType = RecurringType.none,
    this.notificationEnabled = true,
    this.notificationId,
    required this.userId,
    required this.createdAt,
  });

  Event copyWith({
    String? id,
    String? title,
    EventType? type,
    DateTime? dateTime,
    String? notes,
    String? outfitSuggestion,
    bool? isRecurring,
    RecurringType? recurringType,
    bool? notificationEnabled,
    int? notificationId,
    String? userId,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      outfitSuggestion: outfitSuggestion ?? this.outfitSuggestion,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'dateTime': Timestamp.fromDate(dateTime),
      'notes': notes,
      'outfitSuggestion': outfitSuggestion,
      'isRecurring': isRecurring,
      'recurringType': recurringType.name,
      'notificationEnabled': notificationEnabled,
      'notificationId': notificationId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      type: EventType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EventType.personal,
      ),
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      notes: map['notes'] as String? ?? '',
      outfitSuggestion: map['outfitSuggestion'] as String?,
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurringType: RecurringType.values.firstWhere(
        (e) => e.name == map['recurringType'],
        orElse: () => RecurringType.none,
      ),
      notificationEnabled: map['notificationEnabled'] as bool? ?? true,
      notificationId: map['notificationId'] as int?,
      userId: map['userId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  static String typeLabel(EventType type) {
    switch (type) {
      case EventType.work:
        return 'Work';
      case EventType.gym:
        return 'Gym';
      case EventType.social:
        return 'Social';
      case EventType.personal:
        return 'Personal';
      case EventType.appointment:
        return 'Appointment';
    }
  }

  static const Map<EventType, int> typeColors = {
    EventType.work: 0xFF3B82F6,
    EventType.gym: 0xFF10B981,
    EventType.social: 0xFFEC4899,
    EventType.personal: 0xFF8B5CF6,
    EventType.appointment: 0xFFF59E0B,
  };
}
