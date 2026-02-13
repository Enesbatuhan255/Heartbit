import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/bucket_item.dart';

abstract class ActivityRemoteDataSource {
  Stream<List<Activity>> watchActivities();
  Future<void> recordSwipe(String coupleId, String activityId, String odCiU4q9nSb, bool liked);
  Future<bool> checkForMatch(String coupleId, String activityId);
  Future<void> addToBucketList(String coupleId, String activityId);
  Stream<List<BucketItem>> watchBucketList(String coupleId);
  Future<void> updateBucketItemStatus(String coupleId, String itemId, String status, {DateTime? plannedDate});
  Future<void> logWheelSpin(String coupleId, String activityId, String source, String odCiU4q9nSb);
  Future<List<String>> getSwipedActivityIds(String coupleId, String odCiU4q9nSb);
}

class ActivityRemoteDataSourceImpl implements ActivityRemoteDataSource {
  final FirebaseFirestore _firestore;

  ActivityRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _activitiesCollection => _firestore.collection('activities');
  
  DocumentReference _coupleDoc(String coupleId) => _firestore.collection('couples').doc(coupleId);

  @override
  Stream<List<Activity>> watchActivities() {
    return _activitiesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Activity.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  @override
  Future<void> recordSwipe(String coupleId, String activityId, String odCiU4q9nSb, bool liked) async {
    final swipeRef = _coupleDoc(coupleId).collection('swipes').doc(activityId);
    
    await swipeRef.set({
      odCiU4q9nSb: {
        'liked': liked,
        'swipedAt': Timestamp.now(),
      },
    }, SetOptions(merge: true));
  }

  @override
  Future<bool> checkForMatch(String coupleId, String activityId) async {
    final swipeDoc = await _coupleDoc(coupleId).collection('swipes').doc(activityId).get();
    
    if (!swipeDoc.exists) return false;
    
    final data = swipeDoc.data() as Map<String, dynamic>;
    
    // Check if we have exactly 2 users who both liked
    final entries = data.entries.toList();
    if (entries.length < 2) return false;
    
    final allLiked = entries.every((entry) {
      final userSwipe = entry.value as Map<String, dynamic>;
      return userSwipe['liked'] == true;
    });
    
    return allLiked;
  }

  @override
  Future<void> addToBucketList(String coupleId, String activityId) async {
    final bucketRef = _coupleDoc(coupleId).collection('bucketList').doc();
    
    await bucketRef.set({
      'activityId': activityId,
      'matchedAt': Timestamp.now(),
      'status': 'pending',
      'plannedDate': null,
      'completedAt': null,
    });
  }

  @override
  Stream<List<BucketItem>> watchBucketList(String coupleId) {
    return _coupleDoc(coupleId)
        .collection('matches') // CHANGED: Listen to matches, not bucketList
        .orderBy('matchedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BucketItem(
          id: doc.id,
          activityId: data['activityId'] as String,
          matchedAt: _parseDate(data['matchedAt']),
          status: data['status'] as String? ?? 'pending',
          plannedDate: data['plannedDate'] != null 
              ? _parseDate(data['plannedDate']) 
              : null,
          completedAt: data['completedAt'] != null 
              ? _parseDate(data['completedAt']) 
              : null,
        );
      }).toList();
    });
  }

  /// Helper to parse date from either Timestamp or ISO8601 String
  DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else {
      return DateTime.now(); // Fallback
    }
  }

  @override
  Future<void> updateBucketItemStatus(
    String coupleId, 
    String itemId, 
    String status, 
    {DateTime? plannedDate}
  ) async {
    final updateData = <String, dynamic>{
      'status': status,
    };
    
    if (plannedDate != null) {
      updateData['plannedDate'] = Timestamp.fromDate(plannedDate);
    }
    
    if (status == 'completed') {
      updateData['completedAt'] = Timestamp.now();
    }
    
    await _coupleDoc(coupleId).collection('bucketList').doc(itemId).update(updateData);
  }

  @override
  Future<void> logWheelSpin(String coupleId, String activityId, String source, String odCiU4q9nSb) async {
    await _coupleDoc(coupleId).collection('wheelHistory').add({
      'result': activityId,
      'source': source,
      'spunAt': Timestamp.now(),
      'spunBy': odCiU4q9nSb,
    });
  }

  @override
  Future<List<String>> getSwipedActivityIds(String coupleId, String odCiU4q9nSb) async {
    final swipesSnapshot = await _coupleDoc(coupleId).collection('swipes').get();
    
    final swipedIds = <String>[];
    for (final doc in swipesSnapshot.docs) {
      final data = doc.data();
      if (data.containsKey(odCiU4q9nSb)) {
        swipedIds.add(doc.id);
      }
    }
    
    return swipedIds;
  }
}
