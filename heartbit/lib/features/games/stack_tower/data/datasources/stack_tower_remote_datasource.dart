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

  StackTowerRemoteDataSourceImpl({required FirebaseFirestore firestore}) 
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _sessionsRef() {
    return _firestore.collection('stack_tower_sessions');
  }

  @override
  Future<StackTowerSession> createSession({
    required String coupleId,
    required String startingUserId,
    required String partnerId,
  }) async {
    developer.log('[StackTower] createSession called - coupleId: $coupleId, userId: $startingUserId, partnerId: $partnerId');
    
    // Check for existing active session
    final existing = await _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .limit(1)
        .get();

    developer.log('[StackTower] Existing active sessions found: ${existing.docs.length}');

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final data = doc.data();
      developer.log('[StackTower] Found session ${doc.id} - status: ${data['status']}, readyUsers: ${data['readyUsers']}');
      
      // If session exists, add this user as ready and return
      if (data['status'] == 'waiting') {
        final currentReady = List<String>.from(data['readyUsers'] ?? []);
        if (!currentReady.contains(startingUserId)) {
          developer.log('[StackTower] Adding $startingUserId to readyUsers');
          await doc.reference.update({
            'readyUsers': FieldValue.arrayUnion([startingUserId]),
          });
          
          // Notify the waiting partner that you joined
          // Get the first user who created the session
          final waitingUserId = currentReady.isNotEmpty ? currentReady.first : partnerId;
          if (waitingUserId != startingUserId) {
            await _firestore.collection('notifications').add({
              'targetUserId': waitingUserId,
              'fromUserId': startingUserId,
              'type': 'stack_tower_partner_joined',
              'title': 'Stack Tower 🎮',
              'body': 'Partnerin oyuna katıldı! Oyun başlıyor...',
              'coupleId': coupleId,
              'sessionId': doc.id,
              'createdAt': FieldValue.serverTimestamp(),
              'sent': false,
            });
          }
        }
        // Re-fetch the document to get fresh data after arrayUnion update
        final freshDoc = await doc.reference.get();
        final freshSession = _sessionFromSnapshot(freshDoc);
        developer.log('[StackTower] Returning fresh session - readyUsers: ${freshSession.readyUsers}');
        return freshSession;
      }
      
      // If still playing, return existing
      if (data['status'] == 'playing') {
        developer.log('[StackTower] Session is playing, returning existing');
        final freshDoc = await doc.reference.get();
        return _sessionFromSnapshot(freshDoc);
      }
      
      // If status is 'gameover' or 'cancelled', we should deactivate it and create a new one
      // This fixes the bug where "Play Again" resumes the old game
      developer.log('[StackTower] Found active session with status: ${data['status']} - Deactivating and creating NEW one');
      await doc.reference.update({'active': false});
    }

    developer.log('[StackTower] Creating NEW session for couple: $coupleId');
    final docRef = _sessionsRef().doc();
    final now = DateTime.now();

    // Create base block (centered, standard width)
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
      status: 'waiting', // Start in waiting state
      speed: 1.0,
      score: 0,
      createdAt: now,
      active: true,
      readyUsers: [startingUserId], // First user is ready
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

    // Send notification to partner
    await _firestore.collection('notifications').add({
      'targetUserId': partnerId,
      'fromUserId': startingUserId,
      'type': 'stack_tower_invite',
      'title': 'Stack Tower 🎮',
      'body': 'Partnerin seni Stack Tower oynamaya çağırıyor!',
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
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return _sessionFromDoc(snapshot.docs.first);
    });
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    // Cancel = deactivate and reset
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
    // Create base block
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
      'readyUsers': [userId], // Only the restarter is ready
      'currentTurnUserId': userId, // Reset turn to restarter (or randomize?)
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
      score: data['score'] as int,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      active: data['active'] as bool? ?? true,
      readyUsers: List<String>.from(data['readyUsers'] ?? []),
    );
  }
}
