import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/couple_model.dart';

/// Remote data source for pairing operations with Firestore
abstract class PairingRemoteDataSource {
  Future<String> generatePairingCode(String userId);
  Future<String?> validatePairingCode(String code);
  Future<CoupleModel> createCouple(String user1Id, String user2Id, String code);
  Future<String?> getCurrentPairingCode(String userId);
  Future<void> cancelPairingCode(String userId);
  Future<CoupleModel?> getCoupleForUser(String userId);
  Stream<CoupleModel?> watchCoupleForUser(String userId);
}

class PairingRemoteDataSourceImpl implements PairingRemoteDataSource {
  final FirebaseFirestore _firestore;

  PairingRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _couplesCollection =>
      _firestore.collection('couples');

  /// Generates a unique 6-character alphanumeric code
  /// Excludes ambiguous characters: 0, O, 1, I, L
  String _generateCode() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Future<String> generatePairingCode(String userId) async {
    String code;
    bool isUnique = false;

    // Generate unique code
    do {
      code = _generateCode();
      final existingUser = await _usersCollection
          .where('pairingCode', isEqualTo: code)
          .where('pairingCodeExpiresAt', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();
      isUnique = existingUser.docs.isEmpty;
    } while (!isUnique);

    // Set expiration to 24 hours from now
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    // Update or create user document with pairing code (merge: true creates if not exists)
    await _usersCollection.doc(userId).set({
      'pairingCode': code,
      'pairingCodeExpiresAt': Timestamp.fromDate(expiresAt),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));

    return code;
  }

  @override
  Future<String?> validatePairingCode(String code) async {
    final query = await _usersCollection
        .where('pairingCode', isEqualTo: code.toUpperCase())
        .where('pairingCodeExpiresAt', isGreaterThan: Timestamp.now())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.id; // Return user ID
  }

  @override
  Future<CoupleModel> createCouple(String user1Id, String user2Id, String code) async {
    final now = DateTime.now();
    final codeUpper = code.toUpperCase();
    final coupleRef = _couplesCollection.doc();

    await _firestore.runTransaction((tx) async {
      final user1Ref = _usersCollection.doc(user1Id);
      final user2Ref = _usersCollection.doc(user2Id);
      final user1Doc = await tx.get(user1Ref);
      final user2Doc = await tx.get(user2Ref);

      if (!user1Doc.exists || !user2Doc.exists) {
        throw Exception('User profile not found');
      }

      final user1Data = user1Doc.data() ?? {};
      final user2Data = user2Doc.data() ?? {};

      if (user1Data['coupleId'] != null || user2Data['coupleId'] != null) {
        throw Exception('One of the users is already paired');
      }

      final partnerCode = user2Data['pairingCode'] as String?;
      final expiresAt = user2Data['pairingCodeExpiresAt'] as Timestamp?;
      if (partnerCode == null || expiresAt == null || expiresAt.toDate().isBefore(DateTime.now())) {
        throw Exception('Invalid or expired pairing code');
      }
      if (partnerCode.toUpperCase() != codeUpper) {
        throw Exception('Pairing code mismatch');
      }

      final coupleData = {
        'user1Id': user1Id,
        'user2Id': user2Id,
        'totalPoints': 0,
        'level': 1,
        'eggWarmth': 0,
        'isHatched': false,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      tx.set(coupleRef, coupleData);
      tx.set(user1Ref, {
        'coupleId': coupleRef.id,
        'pairingCode': null,
        'pairingCodeExpiresAt': null,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
      tx.set(user2Ref, {
        'coupleId': coupleRef.id,
        'pairingCode': null,
        'pairingCodeExpiresAt': null,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    });

    return CoupleModel(
      id: coupleRef.id,
      user1Id: user1Id,
      user2Id: user2Id,
      totalPoints: 0,
      level: 1,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<String?> getCurrentPairingCode(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    final code = data['pairingCode'] as String?;
    final expiresAt = data['pairingCodeExpiresAt'] as Timestamp?;

    if (code == null || expiresAt == null) return null;
    if (expiresAt.toDate().isBefore(DateTime.now())) return null;

    return code;
  }

  @override
  Future<void> cancelPairingCode(String userId) async {
    await _usersCollection.doc(userId).update({
      'pairingCode': null,
      'pairingCodeExpiresAt': null,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<CoupleModel?> getCoupleForUser(String userId) async {
    // Check user1Id
    var query = await _couplesCollection
        .where('user1Id', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return CoupleModel.fromDocument(query.docs.first);
    }

    // Check user2Id
    query = await _couplesCollection
        .where('user2Id', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return CoupleModel.fromDocument(query.docs.first);
    }

    return null;
  }

  @override
  Stream<CoupleModel?> watchCoupleForUser(String userId) {
    // First get the user to find their coupleId
    return _usersCollection.doc(userId).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) return null;

      final coupleId = userDoc.data()?['coupleId'] as String?;
      if (coupleId == null) return null;

      final coupleDoc = await _couplesCollection.doc(coupleId).get();
      if (!coupleDoc.exists) return null;

      return CoupleModel.fromDocument(coupleDoc);
    });
  }
}
