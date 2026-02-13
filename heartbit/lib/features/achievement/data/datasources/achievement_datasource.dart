
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/achievement.dart';

abstract class AchievementDataSource {
  Stream<List<UnlockedAchievement>> watchUnlockedAchievements(String coupleId);
  Future<void> unlockAchievement(String coupleId, String achievementId);
  Future<void> claimAchievement(String coupleId, String achievementId);
  Future<bool> isUnlocked(String coupleId, String achievementId);
}

class AchievementDataSourceImpl implements AchievementDataSource {
  final FirebaseFirestore _firestore;

  AchievementDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _achievementsCollection(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('achievements');

  @override
  Stream<List<UnlockedAchievement>> watchUnlockedAchievements(String coupleId) {
    return _achievementsCollection(coupleId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UnlockedAchievement(
          achievementId: doc.id,
          unlockedAt: (data['unlockedAt'] as Timestamp).toDate(),
          isClaimed: data['isClaimed'] as bool? ?? false,
        );
      }).toList();
    });
  }

  @override
  Future<void> unlockAchievement(String coupleId, String achievementId) async {
    final docRef = _achievementsCollection(coupleId).doc(achievementId);
    
    // Use transaction to prevent duplicate unlocks from multiple devices
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      
      if (doc.exists) return; // Already unlocked - do nothing
      
      transaction.set(docRef, {
        'unlockedAt': FieldValue.serverTimestamp(),
        'isClaimed': false,
      });
    });
  }

  @override
  Future<void> claimAchievement(String coupleId, String achievementId) async {
    final docRef = _achievementsCollection(coupleId).doc(achievementId);
    
    // Use transaction to prevent double claiming
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;
      
      final isClaimed = doc.data()?['isClaimed'] as bool? ?? false;
      if (isClaimed) return; // Already claimed
      
      transaction.update(docRef, {
        'isClaimed': true,
        'claimedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<bool> isUnlocked(String coupleId, String achievementId) async {
    final doc = await _achievementsCollection(coupleId).doc(achievementId).get();
    return doc.exists;
  }
}
