import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/custom_activity.dart';
import '../../domain/entities/swipe_session.dart';

/// Data source for global activities (public seed data)
abstract class GlobalActivityDataSource {
  Stream<List<Activity>> watchAll();
  Future<List<Activity>> getByCategories(List<String> categories, {int limit = 20});
  Future<Activity?> getById(String id);
}

class GlobalActivityDataSourceImpl implements GlobalActivityDataSource {
  final FirebaseFirestore _firestore;

  GlobalActivityDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _collection => _firestore.collection('global_activities');

  @override
  Stream<List<Activity>> watchAll() {
    return _collection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Activity.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList());
  }

  @override
  Future<List<Activity>> getByCategories(List<String> categories, {int limit = 20}) async {
    if (categories.isEmpty) {
      // Return all active activities if no category selected
      final snapshot = await _collection
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => Activity.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    }

    final snapshot = await _collection
        .where('category', whereIn: categories)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Activity.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }))
        .toList();
  }

  @override
  Future<Activity?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Activity.fromJson({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }
}

/// Data source for couple's custom activities
abstract class CustomActivityDataSource {
  Stream<List<CustomActivity>> watchAll(String coupleId);
  Future<List<CustomActivity>> getAll(String coupleId, {int limit = 10});
  Future<void> add(String coupleId, CustomActivity activity);
  Future<void> delete(String coupleId, String activityId);
}

class CustomActivityDataSourceImpl implements CustomActivityDataSource {
  final FirebaseFirestore _firestore;

  CustomActivityDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference _collection(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('custom_activities');

  @override
  Stream<List<CustomActivity>> watchAll(String coupleId) {
    return _collection(coupleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomActivity.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList());
  }

  @override
  Future<List<CustomActivity>> getAll(String coupleId, {int limit = 10}) async {
    final snapshot = await _collection(coupleId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => CustomActivity.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }))
        .toList();
  }

  @override
  Future<void> add(String coupleId, CustomActivity activity) async {
    await _collection(coupleId).doc(activity.id).set({
      'title': activity.title,
      'createdBy': activity.createdBy,
      'createdAt': activity.createdAt.toIso8601String(),
      'category': activity.category,
      'isTemporary': activity.isTemporary,
    });
  }

  @override
  Future<void> delete(String coupleId, String activityId) async {
    await _collection(coupleId).doc(activityId).delete();
  }
}

/// Data source for swipe sessions and blind voting
abstract class SwipeSessionDataSource {
  Future<String> createSession(String coupleId, List<String> categories, int totalCards);
  Future<void> recordSwipe(String coupleId, SwipeRecord swipe);
  Future<SwipeRecord?> getPartnerSwipe(String coupleId, String activityId, String excludeUserId, String sessionId);
  Future<void> createMatch(String coupleId, ActivityMatch match);
  Stream<List<ActivityMatch>> watchMatches(String coupleId);
}

class SwipeSessionDataSourceImpl implements SwipeSessionDataSource {
  final FirebaseFirestore _firestore;

  SwipeSessionDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference _swipesCollection(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('swipes');

  CollectionReference _matchesCollection(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('matches');

  CollectionReference _sessionsCollection(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('swipe_sessions');

  @override
  Future<String> createSession(String coupleId, List<String> categories, int totalCards) async {
    final docRef = await _sessionsCollection(coupleId).add({
      'selectedCategories': categories,
      'startedAt': FieldValue.serverTimestamp(),
      'totalCards': totalCards,
      'swipedCount': 0,
      'matchCount': 0,
    });
    return docRef.id;
  }

  @override
  Future<void> recordSwipe(String coupleId, SwipeRecord swipe) async {
    await _swipesCollection(coupleId).add({
      'activityId': swipe.activityId,
      'activityType': swipe.activityType,
      'userId': swipe.userId,
      'direction': swipe.direction,
      'sessionId': swipe.sessionId,
      'timestamp': swipe.timestamp.toIso8601String(),
    });
  }

  @override
  Future<SwipeRecord?> getPartnerSwipe(
    String coupleId,
    String activityId,
    String excludeUserId,
    String sessionId,
  ) async {
    print('🔍 getPartnerSwipe: Searching for partner swipe (activityId: $activityId, sessionId: $sessionId, excludeUserId: $excludeUserId)');

    final snapshot = await _swipesCollection(coupleId)
        .where('activityId', isEqualTo: activityId)
        .where('sessionId', isEqualTo: sessionId)
        .get();

    print('🔍 getPartnerSwipe: Found ${snapshot.docs.length} total swipes for this activity in this session');

    final partnerSwipes = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'];
      final isPartner = userId != excludeUserId;
      print('  - Swipe by $userId (direction: ${data['direction']}, isPartner: $isPartner)');
      return isPartner;
    }).toList();

    if (partnerSwipes.isEmpty) {
      print('❌ getPartnerSwipe: No partner swipe found');
      return null;
    }

    final data = partnerSwipes.first.data() as Map<String, dynamic>;
    print('✅ getPartnerSwipe: Found partner swipe! direction=${data['direction']}');
    return SwipeRecord(
      activityId: data['activityId'],
      activityType: data['activityType'] ?? 'global',
      userId: data['userId'],
      direction: data['direction'],
      sessionId: data['sessionId'],
      timestamp: DateTime.parse(data['timestamp']),
    );
  }

  @override
  Future<void> createMatch(String coupleId, ActivityMatch match) async {
    print('💕 createMatch: Creating match ${match.id} for couple $coupleId');
    print('   - Activity: ${match.activityTitle} (${match.activityId})');
    print('   - Type: ${match.activityType}');
    print('   - MatchedAt: ${match.matchedAt}');

    try {
      // Check if match already exists to avoid race condition
      final existingDoc = await _matchesCollection(coupleId).doc(match.id).get();
      if (existingDoc.exists) {
        print('⚠️ createMatch: Match already exists, skipping creation');
        return;
      }

      await _matchesCollection(coupleId).doc(match.id).set({
        'activityId': match.activityId,
        'activityType': match.activityType,
        'activityTitle': match.activityTitle,
        'matchedAt': match.matchedAt.toIso8601String(),
        'status': match.status,
        'plannedDate': match.plannedDate?.toIso8601String(),
        'completedAt': match.completedAt?.toIso8601String(),
      });
      print('✅ createMatch: Match document written to Firestore successfully');
    } catch (e) {
      print('❌ createMatch: Error writing match to Firestore: $e');
      rethrow;
    }
  }

  @override
  Stream<List<ActivityMatch>> watchMatches(String coupleId) {
    print('📡 watchMatches: Listening to couples/$coupleId/matches');
    return _matchesCollection(coupleId)
        .orderBy('matchedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('📡 watchMatches: Got ${snapshot.docs.length} documents');
          return snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              print('  - Doc ${doc.id}: ${data['activityTitle']}');
              return ActivityMatch(
                id: doc.id,
                activityId: data['activityId'],
                activityType: data['activityType'] ?? 'global',
                activityTitle: data['activityTitle'],
                matchedAt: DateTime.parse(data['matchedAt']),
                status: data['status'] ?? 'pending',
                plannedDate: data['plannedDate'] != null
                    ? DateTime.parse(data['plannedDate'])
                    : null,
                completedAt: data['completedAt'] != null
                    ? DateTime.parse(data['completedAt'])
                    : null,
              );
            })
            .toList();
        });
  }
}
