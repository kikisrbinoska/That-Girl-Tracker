import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/step_data.dart';

class StepService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool get _isWebOrDesktop => kIsWeb;

  /// Returns a stream of step counts. On web/desktop, emits mock data.
  Stream<int> stepCountStream() {
    if (_isWebOrDesktop) {
      return Stream.value(5234);
    }
    // On real devices, use pedometer package
    // Pedometer.stepCountStream gives cumulative steps since boot
    // We track the difference from midnight
    return Stream.value(0);
  }

  Future<StepData> getTodaySteps() async {
    final uid = _userId;
    if (uid == null) {
      return StepData(
        date: DateTime.now(),
        stepCount: _isWebOrDesktop ? 5234 : 0,
        lastUpdated: DateTime.now(),
        userId: '',
      );
    }

    final today = DateTime.now();
    final key = _dateKey(today);
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('steps')
        .doc(key)
        .get();

    if (doc.exists) {
      return StepData.fromMap(doc.data()!);
    }

    // Return mock for web or empty for device
    return StepData(
      date: today,
      stepCount: _isWebOrDesktop ? 5234 : 0,
      lastUpdated: DateTime.now(),
      userId: uid,
    );
  }

  Future<void> saveSteps(int stepCount) async {
    final uid = _userId;
    if (uid == null) return;

    final today = DateTime.now();
    final key = _dateKey(today);

    final data = StepData(
      date: today,
      stepCount: stepCount,
      lastUpdated: DateTime.now(),
      userId: uid,
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('steps')
        .doc(key)
        .set(data.toMap());
  }

  Future<List<StepData>> getWeeklySteps() async {
    final uid = _userId;
    if (uid == null) return _mockWeeklySteps();

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('steps')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(weekAgo.year, weekAgo.month, weekAgo.day)))
        .orderBy('date')
        .get();

    if (snapshot.docs.isEmpty) return _mockWeeklySteps();

    final results = <StepData>[];
    for (int i = 0; i < 7; i++) {
      final day = DateTime(weekAgo.year, weekAgo.month, weekAgo.day + i);
      final key = _dateKey(day);
      final match = snapshot.docs.where((d) => d.id == key);
      if (match.isNotEmpty) {
        results.add(StepData.fromMap(match.first.data()));
      } else {
        results.add(StepData(
          date: day,
          stepCount: 0,
          lastUpdated: day,
          userId: uid,
        ));
      }
    }
    return results;
  }

  List<StepData> _mockWeeklySteps() {
    final now = DateTime.now();
    final mockCounts = [7832, 6421, 9102, 4567, 8234, 5234, 5234];
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return StepData(
        date: day,
        stepCount: i == 6 ? 5234 : mockCounts[i],
        lastUpdated: day,
        userId: '',
      );
    });
  }
}
