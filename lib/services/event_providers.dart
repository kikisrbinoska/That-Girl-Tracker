import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import 'event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

final eventsStreamProvider = StreamProvider<List<Event>>((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEvents();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final eventTypeFilterProvider = StateProvider<EventType?>((ref) => null);

final selectedDateEventsProvider = Provider<List<Event>>((ref) {
  final eventsAsync = ref.watch(eventsStreamProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final filter = ref.watch(eventTypeFilterProvider);

  return eventsAsync.when(
    data: (events) {
      var filtered = events.where((e) {
        final eventDate = DateTime(
          e.dateTime.year,
          e.dateTime.month,
          e.dateTime.day,
        );
        return eventDate.isAtSameMomentAs(selectedDate);
      }).toList();

      if (filter != null) {
        filtered = filtered.where((e) => e.type == filter).toList();
      }

      filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final todayEventsProvider = Provider<List<Event>>((ref) {
  final eventsAsync = ref.watch(eventsStreamProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return eventsAsync.when(
    data: (events) {
      final filtered = events.where((e) {
        final eventDate = DateTime(
          e.dateTime.year,
          e.dateTime.month,
          e.dateTime.day,
        );
        return eventDate.isAtSameMomentAs(today);
      }).toList();

      filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
