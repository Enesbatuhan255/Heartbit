import 'dart:async';
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

  CollectionReference<Map<String, dynamic>> get _pairingCodesCollection =>
      _firestore.collection('pairing_codes');

  Future<void> _ensureUserDocument(String userId) async {
    await _usersCollection.doc(userId).set({
      'coupleId': null,
      'pairingCode': null,
      'pairingCodeExpiresAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Generates a unique 6-character alphanumeric code
  /// Excludes ambiguous characters: 0, O, 1, I, L
  String _generateCode() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _formatUtcOffset(int offsetMinutes) {
    final sign = offsetMinutes >= 0 ? '+' : '-';
    final absolute = offsetMinutes.abs();
    final hours = (absolute ~/ 60).toString().padLeft(2, '0');
    final minutes = (absolute % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }

  @override
  Future<String> generatePairingCode(String userId) async {
    await _ensureUserDocument(userId);
    // Generate a 6-char code (30^6 ≈ 730M combinations, collision negligible)
    final code = _generateCode();

    // Set expiration to 24 hours from now
    final expiresAt = DateTime.now().add(const Duration(hours: 24));

    // Update or create user document with pairing code (merge: true creates if not exists)
    // coupleId: null is explicitly set so Firestore isEqualTo: null queries work
    await _usersCollection.doc(userId).set({
      'coupleId': null,
      'pairingCode': code,
      'pairingCodeExpiresAt': Timestamp.fromDate(expiresAt),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _pairingCodesCollection.doc(code).set({
      'ownerUserId': userId,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return code;
  }

  @override
  Future<String?> validatePairingCode(String code) async {
    try {
      final codeUpper = code.toUpperCase();
      final doc = await _pairingCodesCollection.doc(codeUpper).get();
      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      final ownerUserId = data['ownerUserId'] as String?;
      final expiresAt = data['expiresAt'] as Timestamp?;
      if (ownerUserId == null || expiresAt == null) return null;
      if (expiresAt.toDate().isBefore(DateTime.now())) return null;

      return ownerUserId;
    } on FirebaseException catch (e) {
      throw Exception('PAIR_VALIDATE_FAILED: ${e.code}');
    }
  }

  @override
  Future<CoupleModel> createCouple(String user1Id, String user2Id, String code) async {
    final now = DateTime.now();
    final timezoneOffsetMinutes = now.timeZoneOffset.inMinutes;
    final timezone = _formatUtcOffset(timezoneOffsetMinutes);
    final codeUpper = code.toUpperCase();
    final coupleRef = _couplesCollection.doc();
    await _ensureUserDocument(user1Id);

    try {
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
          'timezone': timezone,
          'timezoneOffsetMinutes': timezoneOffsetMinutes,
          'eggWarmth': 0,
          'isHatched': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        tx.set(coupleRef, coupleData);
        tx.set(user1Ref, {
          'coupleId': coupleRef.id,
          'pairingCode': null,
          'pairingCodeExpiresAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        tx.set(user2Ref, {
          'coupleId': coupleRef.id,
          'pairingCode': null,
          'pairingCodeExpiresAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } on FirebaseException catch (e) {
      throw Exception('PAIR_TRANSACTION_FAILED: ${e.code}');
    }

    return CoupleModel(
      id: coupleRef.id,
      user1Id: user1Id,
      user2Id: user2Id,
      totalPoints: 0,
      level: 1,
      timezone: timezone,
      timezoneOffsetMinutes: timezoneOffsetMinutes,
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
      'updatedAt': FieldValue.serverTimestamp(),
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
    late final StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> userSub;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? coupleSub;
    String? activeCoupleId;

    return Stream<CoupleModel?>.multi((controller) {
      userSub = _usersCollection.doc(userId).snapshots().listen(
        (userDoc) {
          if (!userDoc.exists) {
            activeCoupleId = null;
            coupleSub?.cancel();
            coupleSub = null;
            controller.add(null);
            return;
          }

          final coupleId = userDoc.data()?['coupleId'] as String?;
          if (coupleId == null) {
            activeCoupleId = null;
            coupleSub?.cancel();
            coupleSub = null;
            controller.add(null);
            return;
          }

          if (activeCoupleId == coupleId && coupleSub != null) {
            return;
          }

          activeCoupleId = coupleId;
          coupleSub?.cancel();
          coupleSub = _couplesCollection.doc(coupleId).snapshots().listen(
            (coupleDoc) {
              if (!coupleDoc.exists) {
                controller.add(null);
                return;
              }
              controller.add(CoupleModel.fromDocument(coupleDoc));
            },
            onError: controller.addError,
          );
        },
        onError: controller.addError,
      );

      controller.onCancel = () async {
        await coupleSub?.cancel();
        await userSub.cancel();
      };
    });
  }
}
