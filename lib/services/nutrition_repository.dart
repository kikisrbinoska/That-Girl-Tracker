import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/water_log.dart';
import '../models/meal.dart';

class NutritionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ── Water Logs ──

  Future<WaterLog> getTodayWaterLog() async {
    final uid = _userId;
    final today = DateTime.now();
    if (uid == null) {
      return WaterLog(date: today, userId: '');
    }

    final key = _dateKey(today);
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('waterLogs')
        .doc(key)
        .get();

    if (doc.exists) return WaterLog.fromMap(doc.data()!);
    return WaterLog(date: today, userId: uid);
  }

  Stream<WaterLog?> watchTodayWaterLog() {
    final uid = _userId;
    if (uid == null) return Stream.value(null);
    final key = _dateKey(DateTime.now());
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('waterLogs')
        .doc(key)
        .snapshots()
        .map((snap) => snap.exists ? WaterLog.fromMap(snap.data()!) : null);
  }

  Future<void> addWaterEntry(int amountMl) async {
    final uid = _userId;
    if (uid == null) return;

    final today = DateTime.now();
    final key = _dateKey(today);
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('waterLogs')
        .doc(key);

    final doc = await docRef.get();
    WaterLog log;
    if (doc.exists) {
      log = WaterLog.fromMap(doc.data()!);
    } else {
      log = WaterLog(date: today, userId: uid);
    }

    final newEntry = WaterEntry(time: DateTime.now(), amountMl: amountMl);
    final updatedEntries = [...log.entries, newEntry];
    final updated = log.copyWith(entries: updatedEntries);
    await docRef.set(updated.toMap());
  }

  // ── Meals ──

  Future<String> uploadMealImage(String mealId, File imageFile) async {
    final uid = _userId;
    if (uid == null) return '';
    final ref = _storage.ref().child('users/$uid/meals/$mealId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  Future<String> uploadMealImageBytes(String mealId, Uint8List bytes) async {
    final uid = _userId;
    if (uid == null) return '';
    final ref = _storage.ref().child('users/$uid/meals/$mealId.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<void> createMeal(Meal meal) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc(meal.id)
        .set(meal.toMap());
  }

  Stream<List<Meal>> getTodayMeals() {
    final uid = _userId;
    if (uid == null) return Stream.value([]);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('meals')
        .where('time',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('time', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snap) => snap.docs.map((d) => Meal.fromMap(d.data())).toList());
  }

  Future<void> deleteMeal(String mealId) async {
    final uid = _userId;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc(mealId)
        .delete();
  }
}
