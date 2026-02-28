
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

abstract class UserRemoteDataSource {
  Stream<UserProfile?> watchUser(String uid);
  Future<UserProfile?> getUser(String uid);
  Future<void> updateStatus(String uid, String status);
  Future<void> updateDisplayName(String uid, String displayName);
  Future<void> updateLastSeen(String uid);
  Future<void> updatePhotoUrl(String uid, String photoUrl);
  Future<void> updateInteraction(String uid);
  Future<void> updateLocation(String uid, double latitude, double longitude);
  Future<void> updateSleepStatus(String uid, bool isSleeping);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Stream<UserProfile?> watchUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfileModel.fromDocument(doc);
    });
  }

  @override
  Future<UserProfile?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromDocument(doc);
  }

  @override
  Future<void> updateStatus(String uid, String status) async {
    await _usersCollection.doc(uid).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> updateDisplayName(String uid, String displayName) async {
    await _usersCollection.doc(uid).update({
      'displayName': displayName,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> updateLastSeen(String uid) async {
    await _usersCollection.doc(uid).update({
      'lastSeen': Timestamp.now(),
      'isOnline': true, // Simplified online logic
    });
  }

  @override
  Future<void> updatePhotoUrl(String uid, String photoUrl) async {
    await _usersCollection.doc(uid).update({
      'photoUrl': photoUrl,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> updateInteraction(String uid) async {
    await _usersCollection.doc(uid).update({
      'lastInteraction': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> updateLocation(String uid, double latitude, double longitude) async {
    await _usersCollection.doc(uid).update({
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> updateSleepStatus(String uid, bool isSleeping) async {
    await _usersCollection.doc(uid).update({
      'isSleeping': isSleeping,
      'updatedAt': Timestamp.now(),
    });
  }
}
