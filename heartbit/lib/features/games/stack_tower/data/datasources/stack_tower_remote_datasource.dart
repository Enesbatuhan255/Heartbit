import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartbit/features/games/stack_tower/domain/entities/stacked_block.dart';

abstract class StackTowerRemoteDataSource {
  /// Create a new game session in waiting state
  Future<StackTowerSession> createSession({
    required String coupleId,
    required String startingUserId,
    required String partnerId,
  });

  /// Join an existing session (mark as ready)
  Future<void> joinSession({
    required String sessionId,
    required String userId,
  });

  /// Start the game when both are ready
  Future<void> startGame(String sessionId);

  /// Place a block - updates game state and switches turn
  Future<void> placeBlock({
    required String sessionId,
    required StackedBlock block,
    required String nextTurnUserId,
    required double newSpeed,
  });

  /// End the game (game over)
  Future<void> endGame(String sessionId, int finalScore);

  /// Watch active session
  Stream<StackTowerSession?> watchActiveSession(String coupleId);

  /// Cancel/leave session - resets the game
  Future<void> cancelSession(String sessionId);

  /// Reset session for a new game (Play Again)
  Future<void> resetSession({
    required String sessionId,
    required String userId,
  });
}

class StackTowerRemoteDataSourceImpl implements StackTowerRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const Duration _waitingSessionTtl = Duration(minutes: 5);

  StackTowerRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _sessionsRef() {
    return _firestore.collection('stack_tower_sessions');
  }

  DateTime _readCreatedAt(Map<String, dynamic> data) {
    return (data['createdAt'] as Timestamp?)?.toDate() ??
        DateTime.now();
  }

  bool _isTerminalStatus(String status) {
    return status == 'gameover' || status == 'cancelled';
  }

  bool _isStaleWaiting(Map<String, dynamic> data) {
    final status = data['status'] as String? ?? '';
    if (status != 'waiting') return false;
    return DateTime.now().difference(_readCreatedAt(data)) > _waitingSessionTtl;
  }

  Future<void> _sendNotificationSafe(Map<String, dynamic> payload) async {
    try {
      await _firestore.collection('notifications').add(payload);
    } catch (e, st) {
      developer.log('[StackTower] Notification write failed: $e', stackTrace: st);
    }
  }

  @override
  Future<StackTowerSession> createSession({
    required String coupleId,
    required String startingUserId,
    required String partnerId,
  }) async {
    developer.log(
      '[StackTower] createSession called - coupleId: $coupleId, userId: $startingUserId, partnerId: $partnerId',
    );

    final existing = await _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .get();

    developer.log('[StackTower] Existing active sessions found: ${existing.docs.length}');

    if (existing.docs.isNotEmpty) {
      final docs = [...existing.docs]
        ..sort((a, b) => _readCreatedAt(b.data()).compareTo(_readCreatedAt(a.data())));

      for (final doc in docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? '';
        developer.log(
          '[StackTower] Candidate session ${doc.id} - status: $status, readyUsers: ${data['readyUsers']}',
        );

        if (_isTerminalStatus(status) || _isStaleWaiting(data)) {
          developer.log('[StackTower] Deactivating stale/terminal session ${doc.id}');
          await doc.reference.update({'active': false});
          continue;
        }

        if (status == 'playing') {
          developer.log('[StackTower] Returning active playing session ${doc.id}');
          final freshDoc = await doc.reference.get();
          return _sessionFromSnapshot(freshDoc);
        }

        if (status == 'waiting') {
          final currentReady = List<String>.from(data['readyUsers'] ?? []);
          if (!currentReady.contains(startingUserId)) {
            await doc.reference.update({
              'readyUsers': FieldValue.arrayUnion([startingUserId]),
            });

            final waitingUserId =
                currentReady.isNotEmpty ? currentReady.first : partnerId;
            if (waitingUserId != startingUserId) {
              await _sendNotificationSafe({
                'targetUserId': waitingUserId,
                'fromUserId': startingUserId,
                'type': 'stack_tower_partner_joined',
                'title': 'Stack Tower',
                'body': 'Your partner joined the game. Starting now!',
                'coupleId': coupleId,
                'sessionId': doc.id,
                'createdAt': FieldValue.serverTimestamp(),
                'sent': false,
              });
            }
          }

          final freshDoc = await doc.reference.get();
          return _sessionFromSnapshot(freshDoc);
        }
      }
    }

    developer.log('[StackTower] Creating NEW session for couple: $coupleId');
    final docRef = _sessionsRef().doc();
    final now = DateTime.now();

    final baseBlock = StackedBlock(
      leftRatio: 0.3,
      widthRatio: 0.4,
      index: 0,
      placedBy: 'system',
      colorIndex: 0,
    );

    final session = StackTowerSession(
      id: docRef.id,
      coupleId: coupleId,
      currentTurnUserId: startingUserId,
      blocks: [baseBlock],
      status: 'waiting',
      speed: 1.0,
      score: 0,
      createdAt: now,
      active: true,
      readyUsers: [startingUserId],
    );

    await docRef.set({
      'id': session.id,
      'coupleId': session.coupleId,
      'currentTurnUserId': session.currentTurnUserId,
      'blocks': session.blocks.map((b) => b.toMap()).toList(),
      'status': session.status,
      'speed': session.speed,
      'score': session.score,
      'createdAt': FieldValue.serverTimestamp(),
      'active': true,
      'readyUsers': session.readyUsers,
    });

    await _sendNotificationSafe({
      'targetUserId': partnerId,
      'fromUserId': startingUserId,
      'type': 'stack_tower_invite',
      'title': 'Stack Tower',
      'body': 'Your partner invited you to play Stack Tower!',
      'coupleId': coupleId,
      'sessionId': session.id,
      'createdAt': FieldValue.serverTimestamp(),
      'sent': false,
    });

    return session;
  }

  @override
  Future<void> joinSession({
    required String sessionId,
    required String userId,
  }) async {
    await _sessionsRef().doc(sessionId).update({
      'readyUsers': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> startGame(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({
      'status': 'playing',
    });
  }

  @override
  Future<void> placeBlock({
    required String sessionId,
    required StackedBlock block,
    required String nextTurnUserId,
    required double newSpeed,
  }) async {
    await _sessionsRef().doc(sessionId).update({
      'blocks': FieldValue.arrayUnion([block.toMap()]),
      'currentTurnUserId': nextTurnUserId,
      'speed': newSpeed,
      'score': FieldValue.increment(1),
    });
  }

  @override
  Future<void> endGame(String sessionId, int finalScore) async {
    await _sessionsRef().doc(sessionId).update({
      'status': 'gameover',
      'score': finalScore,
    });
  }

  @override
  Stream<StackTowerSession?> watchActiveSession(String coupleId) {
    return _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;

      final sessions = snapshot.docs.map(_sessionFromDoc).where((session) {
        return !_isTerminalStatus(session.status);
      }).toList();

      if (sessions.isEmpty) return null;

      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      for (final session in sessions) {
        if (session.status == 'playing') return session;
      }
      for (final session in sessions) {
        if (session.status == 'waiting') return session;
      }

      return sessions.first;
    });
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({
      'active': false,
      'status': 'cancelled',
    });
  }

  @override
  Future<void> resetSession({
    required String sessionId,
    required String userId,
  }) async {
    final baseBlock = StackedBlock(
      leftRatio: 0.3,
      widthRatio: 0.4,
      index: 0,
      placedBy: 'system',
      colorIndex: 0,
    );

    await _sessionsRef().doc(sessionId).update({
      'status': 'waiting',
      'blocks': [baseBlock.toMap()],
      'score': 0,
      'speed': 1.0,
      'active': true,
      'readyUsers': [userId],
      'currentTurnUserId': userId,
    });
  }

  StackTowerSession _sessionFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return _buildSession(doc.id, data);
  }

  StackTowerSession _sessionFromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return _buildSession(doc.id, data);
  }

  StackTowerSession _buildSession(String id, Map<String, dynamic> data) {
    return StackTowerSession(
      id: id,
      coupleId: data['coupleId'] as String,
      currentTurnUserId: data['currentTurnUserId'] as String,
      blocks: (data['blocks'] as List)
          .map((b) => StackedBlock.fromMap(b as Map<String, dynamic>))
          .toList(),
      status: data['status'] as String,
      speed: (data['speed'] as num).toDouble(),
      score: (data['score'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      active: data['active'] as bool? ?? true,
      readyUsers: List<String>.from(data['readyUsers'] ?? []),
    );
  }
}
