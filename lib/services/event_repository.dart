import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';

class EventRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  EventRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _eventsCollection() {
    return _firestore.collection('users').doc(_userId).collection('events');
  }

  Future<void> createEvent(Event event) async {
    if (_userId == null) return;
    await _eventsCollection().doc(event.id).set(event.toMap());
  }

  Future<void> createRecurringEvents(Event baseEvent) async {
    if (_userId == null) return;

    final batch = _firestore.batch();
    final instances = _generateRecurringInstances(baseEvent);

    for (final event in instances) {
      batch.set(_eventsCollection().doc(event.id), event.toMap());
    }

    await batch.commit();
  }

  List<Event> _generateRecurringInstances(Event baseEvent) {
    final instances = <Event>[];
    final now = baseEvent.dateTime;

    if (baseEvent.recurringType == RecurringType.daily) {
      for (int i = 0; i < 30; i++) {
        final date = now.add(Duration(days: i));
        instances.add(baseEvent.copyWith(
          id: '${baseEvent.id}_$i',
          dateTime: date,
        ));
      }
    } else if (baseEvent.recurringType == RecurringType.weekly) {
      for (int i = 0; i < 5; i++) {
        final date = now.add(Duration(days: i * 7));
        instances.add(baseEvent.copyWith(
          id: '${baseEvent.id}_$i',
          dateTime: date,
        ));
      }
    } else {
      instances.add(baseEvent);
    }

    return instances;
  }

  Stream<List<Event>> getEvents() {
    if (_userId == null) return Stream.value([]);
    return _eventsCollection()
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList());
  }

  Future<void> updateEvent(Event event) async {
    if (_userId == null) return;
    await _eventsCollection().doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    if (_userId == null) return;
    await _eventsCollection().doc(eventId).delete();
  }
}
