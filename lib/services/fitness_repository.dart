import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/workout.dart';
import '../models/training_plan.dart';

class FitnessRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // ── Workouts ──

  Future<void> createWorkout(Workout workout) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .doc(workout.id)
        .set(workout.toMap());
  }

  Stream<List<Workout>> getWorkouts() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Workout.fromMap(d.data())).toList());
  }

  Stream<List<Workout>> getTodayWorkouts() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) => snap.docs.map((d) => Workout.fromMap(d.data())).toList());
  }

  Future<void> deleteWorkout(String workoutId) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .doc(workoutId)
        .delete();
  }

  // ── Training Plan ──

  Future<void> saveTrainingPlan(TrainingPlan plan) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('trainingPlan')
        .doc(plan.dayOfWeek.toString())
        .set(plan.toMap());
  }

  Stream<List<TrainingPlan>> getTrainingPlan() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('trainingPlan')
        .orderBy('dayOfWeek')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TrainingPlan.fromMap(d.data())).toList());
  }

  Future<TrainingPlan?> getTodayTrainingPlan() async {
    final uid = _userId;
    if (uid == null) return null;
    final dayOfWeek = DateTime.now().weekday; // 1=Mon, 7=Sun
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('trainingPlan')
        .doc(dayOfWeek.toString())
        .get();
    if (doc.exists) return TrainingPlan.fromMap(doc.data()!);
    return null;
  }

  Future<void> deleteTrainingPlan(int dayOfWeek) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('trainingPlan')
        .doc(dayOfWeek.toString())
        .delete();
  }
}
