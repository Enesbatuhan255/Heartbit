import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartbit/features/games/story_chain/domain/entities/story_chain_session.dart';
import 'package:heartbit/features/games/story_chain/domain/repositories/story_chain_repository.dart';
import 'package:heartbit/features/games/story_chain/domain/utils/story_chain_validator.dart';

class StoryChainRepositoryImpl implements StoryChainRepository {
  StoryChainRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  static const Duration _waitingSessionTtl = Duration(minutes: 5);

  CollectionReference<Map<String, dynamic>> _sessionsRef() {
    return _firestore.collection('story_chain_sessions');
  }

  DateTime _readCreatedAt(Map<String, dynamic> data) {
    final value = data['createdAt'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  bool _isTerminalStatus(String status) {
    return status == 'completed' || status == 'cancelled';
  }

  bool _isStaleWaiting(Map<String, dynamic> data) {
    final status = data['status'] as String? ?? '';
    if (status != 'waiting') return false;
    return DateTime.now().difference(_readCreatedAt(data)) > _waitingSessionTtl;
  }

  List<String> _normalizeParticipants(
    StoryChainSession session, {
    String? userId,
    String? partnerId,
  }) {
    final participants = <String>{
      ...session.participants.where((e) => e.isNotEmpty),
    };

    final currentTurnUserId = session.currentTurnUserId;
    if (currentTurnUserId != null && currentTurnUserId.isNotEmpty) {
      participants.add(currentTurnUserId);
    }

    if (userId != null && userId.isNotEmpty) participants.add(userId);
    if (partnerId != null && partnerId.isNotEmpty) participants.add(partnerId);

    return participants.toList(growable: false);
  }

  Future<void> _sendNotificationSafe({
    required String targetUserId,
    required String fromUserId,
    required String coupleId,
    required String sessionId,
    required String type,
    required String title,
    required String body,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'targetUserId': targetUserId,
        'fromUserId': fromUserId,
        'type': type,
        'title': title,
        'body': body,
        'coupleId': coupleId,
        'sessionId': sessionId,
        'createdAt': FieldValue.serverTimestamp(),
        'sent': false,
      });
    } catch (error, stackTrace) {
      developer.log(
        '[StoryChain] notification write failed: $error',
        stackTrace: stackTrace,
      );
    }
  }

  void _maybeWriteMemoryInTransaction({
    required Transaction transaction,
    required StoryChainSession session,
    required List<Map<String, dynamic>> turns,
    required String endedByUserId,
    required Map<String, dynamic> updates,
  }) {
    if (session.memorySaved) {
      updates['memorySaved'] = true;
      return;
    }

    final finalText = turns
        .map((turn) => (turn['text'] as String? ?? '').trim())
        .where((text) => text.isNotEmpty)
        .join(' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (finalText.isEmpty) {
      updates['memorySaved'] = false;
      return;
    }

    final memoryRef = _firestore
        .collection('couples')
        .doc(session.coupleId)
        .collection('memories')
        .doc();

    transaction.set(memoryRef, {
      'coupleId': session.coupleId,
      'imageUrl': '',
      'date': FieldValue.serverTimestamp(),
      'description': finalText,
      'title': 'Hikaye Oyunu',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': endedByUserId,
      'sourceGame': 'story_chain',
    });

    updates['memorySaved'] = true;
  }

  @override
  Future<void> enterGame({
    required String coupleId,
    required String userId,
    required String partnerId,
    required StoryMode mode,
  }) async {
    final existing = await _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .get();

    if (existing.docs.isNotEmpty) {
      final docs = [...existing.docs]..sort(
          (a, b) =>
              _readCreatedAt(b.data()).compareTo(_readCreatedAt(a.data())),
        );

      for (final doc in docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'waiting';

        if (_isTerminalStatus(status) || _isStaleWaiting(data)) {
          await doc.reference.update({
            'active': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          continue;
        }

        if (status == 'playing') {
          return;
        }

        if (status == 'waiting') {
          final session = StoryChainSession.fromMap(doc.id, data);
          final participants = _normalizeParticipants(
            session,
            userId: userId,
            partnerId: partnerId,
          );
          final readyUsers = List<String>.from(data['readyUsers'] ?? const []);

          final updates = <String, dynamic>{
            'participants': participants,
            'requiredWordCount': StoryChainSession.requiredWordCountFor(
              mode: session.mode,
              successfulTurnCount: session.successfulTurnCount,
            ),
            'successfulTurnCount': session.successfulTurnCount,
            'maxTurns': session.maxTurns,
            'memorySaved': session.memorySaved,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          if (!readyUsers.contains(userId)) {
            updates['readyUsers'] = FieldValue.arrayUnion([userId]);
          }

          await doc.reference.update(updates);

          if (!readyUsers.contains(userId)) {
            final waitingUserId =
                readyUsers.isNotEmpty ? readyUsers.first : partnerId;
            if (waitingUserId != userId) {
              await _sendNotificationSafe(
                targetUserId: waitingUserId,
                fromUserId: userId,
                coupleId: coupleId,
                sessionId: doc.id,
                type: 'story_chain_partner_joined',
                title: 'Story Chain',
                body: 'Partnerin oyuna katildi. Hikayeyi baslatabilirsiniz.',
              );
            }
          }

          return;
        }
      }
    }

    final sessionRef = _sessionsRef().doc();
    final participants = [userId, partnerId];

    await sessionRef.set({
      'id': sessionRef.id,
      'coupleId': coupleId,
      'status': 'waiting',
      'mode': StoryChainSession.modeToStorage(mode),
      'turns': <Map<String, dynamic>>[],
      'currentTurnUserId': userId,
      'readyUsers': [userId],
      'participants': participants,
      'requiredWordCount': 1,
      'successfulTurnCount': 0,
      'maxTurns': StoryChainSession.defaultMaxTurns,
      'memorySaved': false,
      'active': true,
      'endedByUserId': null,
      'endReason': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _sendNotificationSafe(
      targetUserId: partnerId,
      fromUserId: userId,
      coupleId: coupleId,
      sessionId: sessionRef.id,
      type: 'story_chain_invite',
      title: 'Story Chain',
      body: 'Partnerin seni Story Chain oyununa davet ediyor.',
    );
  }

  @override
  Future<bool> startGame(String sessionId) async {
    return _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return false;

      final session = StoryChainSession.fromMap(snapshot.id, snapshot.data()!);

      if (!session.active ||
          session.status != StoryStatus.waiting ||
          session.readyUsers.length < 2) {
        return false;
      }

      final currentTurnUserId =
          session.currentTurnUserId ?? session.readyUsers.first;
      final requiredWordCount = StoryChainSession.requiredWordCountFor(
        mode: session.mode,
        successfulTurnCount: session.successfulTurnCount,
      );
      final participants = _normalizeParticipants(
        session,
        userId: currentTurnUserId,
      );

      transaction.update(ref, {
        'status': 'playing',
        'currentTurnUserId': currentTurnUserId,
        'participants': participants,
        'requiredWordCount': requiredWordCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  @override
  Future<bool> submitTurn({
    required String sessionId,
    required String userId,
    required String text,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return false;

      final session = StoryChainSession.fromMap(snapshot.id, snapshot.data()!);
      if (!session.active ||
          session.status != StoryStatus.playing ||
          session.currentTurnUserId != userId) {
        return false;
      }

      final validation = StoryChainValidator.validateTurn(text, session);
      if (validation != null) return false;

      final normalizedText = StoryChainValidator.normalizeText(text);
      final wordCount = StoryChainValidator.splitWords(normalizedText).length;

      final updatedTurns = [
        ...session.turns.map((turn) => turn.toMap()),
        StoryTurn(
          text: normalizedText,
          userId: userId,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          wordCount: wordCount,
        ).toMap(),
      ];

      final newSuccessfulTurnCount = session.successfulTurnCount + 1;
      final newRequiredWordCount = StoryChainSession.requiredWordCountFor(
        mode: session.mode,
        successfulTurnCount: newSuccessfulTurnCount,
      );
      final nextTurnUserId = session.partnerOf(userId) ?? userId;
      final shouldComplete = newSuccessfulTurnCount >= session.maxTurns;

      final updates = <String, dynamic>{
        'turns': updatedTurns,
        'successfulTurnCount': newSuccessfulTurnCount,
        'requiredWordCount': newRequiredWordCount,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (shouldComplete) {
        updates.addAll({
          'status': 'completed',
          'currentTurnUserId': null,
          'endedByUserId': userId,
          'endReason': 'max_turns',
        });
        _maybeWriteMemoryInTransaction(
          transaction: transaction,
          session: session,
          turns: updatedTurns,
          endedByUserId: userId,
          updates: updates,
        );
      } else {
        updates['currentTurnUserId'] = nextTurnUserId;
      }

      transaction.update(ref, updates);
      return true;
    });
  }

  @override
  Future<bool> passTurn({
    required String sessionId,
    required String userId,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return false;

      final session = StoryChainSession.fromMap(snapshot.id, snapshot.data()!);
      if (!session.active ||
          session.status != StoryStatus.playing ||
          session.currentTurnUserId != userId) {
        return false;
      }

      final partnerId = session.partnerOf(userId);
      if (partnerId == null || partnerId.isEmpty) return false;

      transaction.update(ref, {
        'currentTurnUserId': partnerId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  @override
  Future<bool> endGame({
    required String sessionId,
    required String userId,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return false;

      final session = StoryChainSession.fromMap(snapshot.id, snapshot.data()!);
      if (!session.active) return false;
      if (session.status != StoryStatus.playing &&
          session.status != StoryStatus.waiting) {
        return false;
      }

      final updates = <String, dynamic>{
        'status': 'completed',
        'currentTurnUserId': null,
        'endedByUserId': userId,
        'endReason': 'ended_by_user',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      _maybeWriteMemoryInTransaction(
        transaction: transaction,
        session: session,
        turns: session.turns.map((turn) => turn.toMap()).toList(),
        endedByUserId: userId,
        updates: updates,
      );

      transaction.update(ref, updates);
      return true;
    });
  }

  @override
  Future<void> leaveGame({
    required String sessionId,
    required String userId,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;

      final session = StoryChainSession.fromMap(snapshot.id, snapshot.data()!);
      if (!session.active) return;

      if (session.status == StoryStatus.waiting ||
          session.status == StoryStatus.playing) {
        transaction.update(ref, {
          'status': 'cancelled',
          'active': false,
          'currentTurnUserId': null,
          'endedByUserId': userId,
          'endReason': 'left',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      transaction.update(ref, {
        'active': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> restartGame({
    required String sessionId,
    required String userId,
    required StoryMode mode,
  }) async {
    final ref = _sessionsRef().doc(sessionId);

    String partnerId = '';
    String? coupleId;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;

      final session = StoryChainSession.fromMap(snapshot.id, snapshot.data()!);
      coupleId = session.coupleId;

      final participants = _normalizeParticipants(
        session,
        userId: userId,
        partnerId: session.partnerOf(userId),
      );

      partnerId = participants.firstWhere(
        (participant) => participant != userId,
        orElse: () => '',
      );

      transaction.update(ref, {
        'status': 'waiting',
        'mode': StoryChainSession.modeToStorage(mode),
        'turns': <Map<String, dynamic>>[],
        'currentTurnUserId': userId,
        'readyUsers': [userId],
        'participants': participants,
        'requiredWordCount': 1,
        'successfulTurnCount': 0,
        'maxTurns': StoryChainSession.defaultMaxTurns,
        'memorySaved': false,
        'endedByUserId': null,
        'endReason': null,
        'active': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    if (partnerId.isNotEmpty && coupleId != null) {
      await _sendNotificationSafe(
        targetUserId: partnerId,
        fromUserId: userId,
        coupleId: coupleId!,
        sessionId: sessionId,
        type: 'story_chain_invite',
        title: 'Story Chain',
        body: 'Partnerin Story Chain icin tekrar davet gonderdi.',
      );
    }
  }

  @override
  Stream<StoryChainSession?> watchSession(String coupleId) {
    return _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;

      final sessions = snapshot.docs
          .map((doc) => StoryChainSession.fromMap(doc.id, doc.data()))
          .where((session) => session.status != StoryStatus.cancelled)
          .toList();

      if (sessions.isEmpty) return null;
      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      for (final session in sessions) {
        if (session.status == StoryStatus.playing) return session;
      }
      for (final session in sessions) {
        if (session.status == StoryStatus.waiting) return session;
      }

      return sessions.first;
    });
  }
}
