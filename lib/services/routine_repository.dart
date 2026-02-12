import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/routine.dart';
import '../models/sleep_log.dart';

class RoutineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ── Routines ──

  Future<Routine> getRoutine(String type) async {
    // type: "morning" or "evening"
    final uid = _userId;
    final today = DateTime.now();
    final key = '${type}_${_dateKey(today)}';

    if (uid == null) {
      return Routine(
        id: type,
        tasks: type == 'morning'
            ? Routine.defaultMorningTasks()
            : Routine.defaultEveningTasks(),
        date: today,
        userId: '',
      );
    }

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('routines')
        .doc(key)
        .get();

    if (doc.exists) return Routine.fromMap(doc.data()!);

    // Create default routine for today
    final routine = Routine(
      id: type,
      tasks: type == 'morning'
          ? Routine.defaultMorningTasks()
          : Routine.defaultEveningTasks(),
      date: today,
      userId: uid,
    );
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('routines')
        .doc(key)
        .set(routine.toMap());
    return routine;
  }

  Stream<Routine?> watchRoutine(String type) {
    final uid = _userId;
    if (uid == null) return Stream.value(null);
    final today = DateTime.now();
    final key = '${type}_${_dateKey(today)}';
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('routines')
        .doc(key)
        .snapshots()
        .map((snap) => snap.exists ? Routine.fromMap(snap.data()!) : null);
  }

  Future<void> toggleTask(String type, String taskId, bool done) async {
    final uid = _userId;
    if (uid == null) return;
    final today = DateTime.now();
    final key = '${type}_${_dateKey(today)}';

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('routines')
        .doc(key)
        .get();

    if (!doc.exists) return;

    final routine = Routine.fromMap(doc.data()!);
    final updatedTasks = routine.tasks.map((t) {
      if (t.id == taskId) return t.copyWith(done: done);
      return t;
    }).toList();

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('routines')
        .doc(key)
        .update({'tasks': updatedTasks.map((t) => t.toMap()).toList()});
  }

  Future<void> saveDayRating(int rating) async {
    final uid = _userId;
    if (uid == null) return;
    final today = DateTime.now();
    final key = 'evening_${_dateKey(today)}';

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('routines')
        .doc(key)
        .update({'dayRating': rating});
  }

  // ── Sleep ──

  Future<void> saveSleepLog(SleepLog log) async {
    final uid = _userId;
    if (uid == null) return;
    final key = _dateKey(log.date);
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('sleep')
        .doc(key)
        .set(log.toMap());
  }

  Future<SleepLog?> getTodaySleepLog() async {
    final uid = _userId;
    if (uid == null) return null;
    final key = _dateKey(DateTime.now());
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('sleep')
        .doc(key)
        .get();
    if (doc.exists) return SleepLog.fromMap(doc.data()!);
    return null;
  }

  Future<List<SleepLog>> getWeeklySleep() async {
    final uid = _userId;
    if (uid == null) return [];
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('sleep')
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(
                DateTime(weekAgo.year, weekAgo.month, weekAgo.day)))
        .orderBy('date')
        .get();

    return snapshot.docs.map((d) => SleepLog.fromMap(d.data())).toList();
  }
}
