import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartbit/features/games/rhythm_copy/domain/entities/rhythm_copy_session.dart';

abstract class RhythmCopyRemoteDataSource {
  Future<RhythmCopySession> createSession({
    required String coupleId,
    required String startingUserId,
    required String partnerId,
  });

  Future<void> startGame(String sessionId);

  Future<void> submitPattern({
    required String sessionId,
    required String composerId,
    required List<int> pattern,
    required List<int> patternTimingsMs,
  });

  Future<void> submitCopy({
    required String sessionId,
    required String copyUserId,
    required List<int> copyInput,
    required List<int> copyInputTimingsMs,
  });

  Future<void> nextRound(String sessionId);

  Future<void> endGame(String sessionId);

  Future<void> sendReaction({
    required String sessionId,
    required String userId,
    required String emoji,
  });

  Stream<RhythmCopySession?> watchActiveSession(String coupleId);

  Future<void> cancelSession(String sessionId);

  Future<void> resetSession({
    required String sessionId,
    required String userId,
  });
}

class RhythmCopyRemoteDataSourceImpl implements RhythmCopyRemoteDataSource {
  final FirebaseFirestore _firestore;

  RhythmCopyRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _sessionsRef() {
    return _firestore.collection('rhythm_copy_sessions');
  }

  Future<void> _sendNotification({
    required String targetUserId,
    required String fromUserId,
    required String type,
    required String title,
    required String body,
    required String coupleId,
    required String sessionId,
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
        '[RhythmCopy] Notification write failed: $error',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<RhythmCopySession> createSession({
    required String coupleId,
    required String startingUserId,
    required String partnerId,
  }) async {
    final existing = await _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final data = doc.data();
      final status = data['status'] as String? ?? 'waiting';

      if (status == 'waiting') {
        final readyUsers = List<String>.from(data['readyUsers'] ?? const []);
        if (!readyUsers.contains(startingUserId)) {
          await doc.reference.update({
            'readyUsers': FieldValue.arrayUnion([startingUserId]),
          });

          final waitingUserId =
              readyUsers.isNotEmpty ? readyUsers.first : partnerId;
          if (waitingUserId != startingUserId) {
            await _sendNotification(
              targetUserId: waitingUserId,
              fromUserId: startingUserId,
              type: 'rhythm_copy_partner_joined',
              title: 'Rhythm Copy',
              body: 'Your partner joined. Start the rhythm duel.',
              coupleId: coupleId,
              sessionId: doc.id,
            );
          }
        }
      }

      final fresh = await doc.reference.get();
      return RhythmCopySession.fromMap(fresh.id, fresh.data()!);
    }

    final docRef = _sessionsRef().doc();
    final participants = [startingUserId, partnerId];
    final scores = {
      startingUserId: 0,
      partnerId: 0,
    };

    await docRef.set({
      'id': docRef.id,
      'coupleId': coupleId,
      'participants': participants,
      'composerId': startingUserId,
      'copyUserId': partnerId,
      'status': 'waiting',
      'round': 1,
      'maxRounds': 6,
      'pattern': <int>[],
      'patternTimingsMs': <int>[],
      'copyInput': <int>[],
      'copyInputTimingsMs': <int>[],
      'scores': scores,
      'lastAccuracy': null,
      'lastNoteAccuracy': null,
      'lastTimingAccuracy': null,
      'lastResponseMs': null,
      'lastRoundWinnerId': null,
      'copyStartedAt': null,
      'reactionEmoji': null,
      'reactionBy': null,
      'reactionAt': null,
      'readyUsers': [startingUserId],
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _sendNotification(
      targetUserId: partnerId,
      fromUserId: startingUserId,
      type: 'rhythm_copy_invite',
      title: 'Rhythm Copy',
      body: 'Your partner invited you to a rhythm duel.',
      coupleId: coupleId,
      sessionId: docRef.id,
    );

    return RhythmCopySession(
      id: docRef.id,
      coupleId: coupleId,
      participants: participants,
      composerId: startingUserId,
      copyUserId: partnerId,
      status: 'waiting',
      round: 1,
      maxRounds: 6,
      pattern: const [],
      patternTimingsMs: const [],
      copyInput: const [],
      copyInputTimingsMs: const [],
      scores: scores,
      reactionEmoji: null,
      reactionBy: null,
      reactionAt: null,
      readyUsers: [startingUserId],
      active: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> startGame(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({
      'status': 'composing',
      'round': 1,
      'pattern': <int>[],
      'patternTimingsMs': <int>[],
      'copyInput': <int>[],
      'copyInputTimingsMs': <int>[],
      'lastAccuracy': null,
      'lastNoteAccuracy': null,
      'lastTimingAccuracy': null,
      'lastResponseMs': null,
      'lastRoundWinnerId': null,
      'copyStartedAt': null,
      'reactionEmoji': null,
      'reactionBy': null,
      'reactionAt': null,
    });
  }

  @override
  Future<void> submitPattern({
    required String sessionId,
    required String composerId,
    required List<int> pattern,
    required List<int> patternTimingsMs,
  }) async {
    await _sessionsRef().doc(sessionId).update({
      'composerId': composerId,
      'pattern': pattern,
      'patternTimingsMs': patternTimingsMs,
      'copyInput': <int>[],
      'copyInputTimingsMs': <int>[],
      'status': 'copying',
      'copyStartedAt': FieldValue.serverTimestamp(),
      'lastAccuracy': null,
      'lastNoteAccuracy': null,
      'lastTimingAccuracy': null,
      'lastResponseMs': null,
      'lastRoundWinnerId': null,
      'reactionEmoji': null,
      'reactionBy': null,
      'reactionAt': null,
    });
  }

  double _calculateNoteAccuracy({
    required List<int> pattern,
    required List<int> input,
  }) {
    if (pattern.isEmpty) return 0;
    final compareLength =
        pattern.length < input.length ? pattern.length : input.length;
    if (compareLength <= 0) return 0;

    var matches = 0;
    for (var i = 0; i < compareLength; i++) {
      if (pattern[i] == input[i]) {
        matches++;
      }
    }

    final base = matches / pattern.length;
    final lengthPenalty = compareLength /
        (pattern.length > input.length ? pattern.length : input.length);
    return (base * lengthPenalty).clamp(0, 1);
  }

  List<int> _intervals(List<int> timingsMs) {
    if (timingsMs.length <= 1) return const [];
    final intervals = <int>[];
    for (var i = 1; i < timingsMs.length; i++) {
      intervals.add((timingsMs[i] - timingsMs[i - 1]).abs());
    }
    return intervals;
  }

  double _calculateTimingAccuracy({
    required List<int> patternTimingsMs,
    required List<int> inputTimingsMs,
  }) {
    if (patternTimingsMs.length <= 1) return 1;
    if (inputTimingsMs.length <= 1) return 0;

    final patternIntervals = _intervals(patternTimingsMs);
    final inputIntervals = _intervals(inputTimingsMs);
    if (patternIntervals.isEmpty || inputIntervals.isEmpty) return 0;

    final compareLength = patternIntervals.length < inputIntervals.length
        ? patternIntervals.length
        : inputIntervals.length;
    if (compareLength <= 0) return 0;

    var total = 0.0;
    for (var i = 0; i < compareLength; i++) {
      final target = patternIntervals[i];
      final actual = inputIntervals[i];
      final tolerance = (target * 0.35).clamp(80, 280).toDouble();
      final diff = (target - actual).abs().toDouble();
      final score = (1 - (diff / tolerance)).clamp(0, 1);
      total += score;
    }

    final average = total / compareLength;
    final lengthPenalty = compareLength /
        (patternIntervals.length > inputIntervals.length
            ? patternIntervals.length
            : inputIntervals.length);
    return (average * lengthPenalty).clamp(0, 1);
  }

  int _copyScore({
    required double accuracy,
    required int responseMs,
  }) {
    var base = 0;
    if (accuracy >= 0.9) {
      base = 5;
    } else if (accuracy >= 0.75) {
      base = 3;
    } else if (accuracy >= 0.55) {
      base = 2;
    } else if (accuracy >= 0.35) {
      base = 1;
    }

    final speedBonus = responseMs <= 2500
        ? 2
        : responseMs <= 4500
            ? 1
            : 0;
    return base + speedBonus;
  }

  @override
  Future<void> submitCopy({
    required String sessionId,
    required String copyUserId,
    required List<int> copyInput,
    required List<int> copyInputTimingsMs,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;

      final session = RhythmCopySession.fromMap(snapshot.id, snapshot.data()!);
      final noteAccuracy =
          _calculateNoteAccuracy(pattern: session.pattern, input: copyInput);
      final timingAccuracy = _calculateTimingAccuracy(
        patternTimingsMs: session.patternTimingsMs,
        inputTimingsMs: copyInputTimingsMs,
      );
      final accuracy = ((noteAccuracy * 0.65) + (timingAccuracy * 0.35))
          .clamp(0, 1)
          .toDouble();

      final responseMs = session.copyStartedAt == null
          ? 0
          : DateTime.now().difference(session.copyStartedAt!).inMilliseconds;

      final copyScore = _copyScore(
        accuracy: accuracy,
        responseMs: responseMs,
      );

      final composerScore = accuracy < 0.8 ? 1 : 0;
      final winnerId =
          copyScore >= composerScore ? copyUserId : session.composerId;

      final updates = <String, dynamic>{
        'copyInput': copyInput,
        'copyInputTimingsMs': copyInputTimingsMs,
        'lastAccuracy': accuracy,
        'lastNoteAccuracy': noteAccuracy,
        'lastTimingAccuracy': timingAccuracy,
        'lastResponseMs': responseMs,
        'lastRoundWinnerId': winnerId,
        'status': 'roundEnd',
      };

      if (copyScore > 0) {
        updates['scores.$copyUserId'] = FieldValue.increment(copyScore);
      }
      if (composerScore > 0) {
        updates['scores.${session.composerId}'] =
            FieldValue.increment(composerScore);
      }

      transaction.update(ref, updates);
    });
  }

  @override
  Future<void> nextRound(String sessionId) async {
    await _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;
      final session = RhythmCopySession.fromMap(snapshot.id, snapshot.data()!);

      if (session.round >= session.maxRounds) {
        transaction.update(ref, {'status': 'gameover'});
        return;
      }

      transaction.update(ref, {
        'round': session.round + 1,
        'composerId': session.copyUserId,
        'copyUserId': session.composerId,
        'status': 'composing',
        'pattern': <int>[],
        'patternTimingsMs': <int>[],
        'copyInput': <int>[],
        'copyInputTimingsMs': <int>[],
        'lastAccuracy': null,
        'lastNoteAccuracy': null,
        'lastTimingAccuracy': null,
        'lastResponseMs': null,
        'lastRoundWinnerId': null,
        'copyStartedAt': null,
        'reactionEmoji': null,
        'reactionBy': null,
        'reactionAt': null,
      });
    });
  }

  @override
  Future<void> endGame(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({'status': 'gameover'});
  }

  @override
  Future<void> sendReaction({
    required String sessionId,
    required String userId,
    required String emoji,
  }) async {
    await _sessionsRef().doc(sessionId).update({
      'reactionEmoji': emoji,
      'reactionBy': userId,
      'reactionAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<RhythmCopySession?> watchActiveSession(String coupleId) {
    return _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return RhythmCopySession.fromMap(doc.id, doc.data());
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
    final doc = await _sessionsRef().doc(sessionId).get();
    if (!doc.exists) return;

    final session = RhythmCopySession.fromMap(doc.id, doc.data()!);
    final partnerId = session.partnerOf(userId) ?? '';

    final resetScores = <String, int>{};
    for (final participant in session.participants) {
      resetScores[participant] = 0;
    }

    await _sessionsRef().doc(sessionId).update({
      'composerId': userId,
      'copyUserId': partnerId,
      'status': 'waiting',
      'round': 1,
      'pattern': <int>[],
      'patternTimingsMs': <int>[],
      'copyInput': <int>[],
      'copyInputTimingsMs': <int>[],
      'scores': resetScores,
      'lastAccuracy': null,
      'lastNoteAccuracy': null,
      'lastTimingAccuracy': null,
      'lastResponseMs': null,
      'lastRoundWinnerId': null,
      'copyStartedAt': null,
      'reactionEmoji': null,
      'reactionBy': null,
      'reactionAt': null,
      'readyUsers': [userId],
      'active': true,
    });
  }
}
