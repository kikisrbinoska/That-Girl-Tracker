import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_review.dart';

class DailyReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> saveDailyReview(DailyReview review) async {
    final uid = _userId;
    if (uid == null) return;

    final map = review.toMap();
    map['userId'] = uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyReviews')
        .doc(review.dateKey)
        .set(map);
  }

  Future<DailyReview?> getDailyReview(DateTime date) async {
    final uid = _userId;
    if (uid == null) return null;

    final key = _dateKey(date);
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyReviews')
        .doc(key)
        .get();

    if (doc.exists && doc.data() != null) {
      return DailyReview.fromMap(key, doc.data()!);
    }
    return null;
  }

  Stream<DailyReview?> watchDailyReview(DateTime date) {
    final uid = _userId;
    if (uid == null) return Stream.value(null);

    final key = _dateKey(date);
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('dailyReviews')
        .doc(key)
        .snapshots()
        .map((snap) =>
            snap.exists && snap.data() != null
                ? DailyReview.fromMap(key, snap.data()!)
                : null);
  }
}
