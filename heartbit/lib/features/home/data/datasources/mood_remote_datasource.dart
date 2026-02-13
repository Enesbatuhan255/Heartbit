import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartbit/features/home/domain/entities/mood.dart';

class MoodRemoteDataSource {
  final FirebaseFirestore _firestore;

  MoodRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _moodCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('mood_history');

  String _dateKey(DateTime date) {
    final utc = date.toUtc();
    return '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
  }

  String _todayKey() => _dateKey(DateTime.now());

  Future<Mood?> getTodaysMood(String userId) async {
    final doc = await _moodCollection(userId).doc(_todayKey()).get();
    if (!doc.exists) return null;
    
    final moodStr = doc.data()?['mood'] as String?;
    if (moodStr == null) return null;
    
    return Mood.values.firstWhere(
      (m) => m.name == moodStr,
      orElse: () => Mood.happy,
    );
  }

  Future<void> setTodaysMood(String userId, Mood mood) async {
    final docRef = _moodCollection(userId).doc(_todayKey());
    
    // Use transaction to prevent race conditions
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      
      dynamic existingCreatedAt;
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          existingCreatedAt = data['createdAt'];
        }
      }
      
      final newData = <String, dynamic>{
        'mood': mood.name,
        'date': _todayKey(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (existingCreatedAt != null) {
        newData['createdAt'] = existingCreatedAt;
      } else {
        newData['createdAt'] = FieldValue.serverTimestamp();
      }

      transaction.set(docRef, newData, SetOptions(merge: true));
    });
  }

  Stream<Mood?> watchTodaysMood(String userId) {
    return _moodCollection(userId).doc(_todayKey()).snapshots().map((doc) {
      if (!doc.exists) return null;
      final moodStr = doc.data()?['mood'] as String?;
      if (moodStr == null) return null;
      return Mood.values.firstWhere((m) => m.name == moodStr, orElse: () => Mood.happy);
    });
  }

  Future<int> getConsecutiveMoodDays(String userId) async {
    // Get last 30 days of mood history - check backwards from today
    final now = DateTime.now().toUtc();
    int consecutiveDays = 0;
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      final doc = await _moodCollection(userId).doc(key).get();
      
      if (doc.exists) {
        consecutiveDays++;
      } else {
        break; // Streak broken
      }
    }
    
    return consecutiveDays;
  }
}
