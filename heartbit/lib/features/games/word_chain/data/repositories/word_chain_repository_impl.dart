import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartbit/features/games/word_chain/domain/entities/word_chain_session.dart';
import 'package:heartbit/features/games/word_chain/domain/repositories/word_chain_repository.dart';
import 'package:heartbit/features/games/word_chain/domain/utils/word_chain_validator.dart';

class WordChainRepositoryImpl implements WordChainRepository {
  WordChainRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  static const Duration _waitingSessionTtl = Duration(minutes: 5);

  CollectionReference<Map<String, dynamic>> _sessionsRef() {
    return _firestore.collection('word_chain_sessions');
  }

  DateTime _readCreatedAt(Map<String, dynamic> data) {
    final value = data['createdAt'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  bool _isTerminalStatus(String status) {
    return status == 'gameover' || status == 'cancelled';
  }

  bool _isStaleWaiting(Map<String, dynamic> data) {
    final status = data['status'] as String? ?? '';
    if (status != 'waiting') return false;
    return DateTime.now().difference(_readCreatedAt(data)) > _waitingSessionTtl;
  }

  int _suffixLengthForSession(WordChainMode mode, int wordCount) {
    if (!WordChainSession.isProgressiveMode(mode)) {
      return WordChainSession.stageOneSuffixLength;
    }
    return WordChainSession.suffixLengthForWordCount(wordCount);
  }

  int _turnSecondsForSession(WordChainMode mode, int requiredSuffixLength) {
    if (!WordChainSession.isProgressiveMode(mode)) {
      return WordChainSession.stageOneTurnSeconds;
    }
    return WordChainSession.turnSecondsForSuffixLength(requiredSuffixLength);
  }

  Timestamp _deadlineFromNow(int seconds) {
    return Timestamp.fromDate(DateTime.now().add(Duration(seconds: seconds)));
  }

  List<String> _normalizeParticipants(
    WordChainSession session, {
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

  int _normalizeJokerValue(int value) {
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  Map<String, int> _defaultJokers(Iterable<String> participants) {
    final jokers = <String, int>{};
    for (final participant in participants) {
      if (participant.isEmpty) continue;
      jokers[participant] = 1;
    }
    return jokers;
  }

  Map<String, int> _normalizeJokers(
    Iterable<String> participants,
    Map<String, int> source,
  ) {
    final jokers = <String, int>{};
    source.forEach((key, value) {
      if (key.isEmpty) return;
      jokers[key] = _normalizeJokerValue(value);
    });

    for (final participant in participants) {
      if (participant.isEmpty) continue;
      jokers.putIfAbsent(participant, () => 1);
    }

    return jokers;
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
        '[WordChain] notification write failed: $error',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> enterGame({
    required String coupleId,
    required String userId,
    required String partnerId,
    required WordChainMode mode,
    String? category,
  }) async {
    final existing = await _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .get();

    if (existing.docs.isNotEmpty) {
      final docs = [...existing.docs]..sort((a, b) =>
          _readCreatedAt(b.data()).compareTo(_readCreatedAt(a.data())));

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
          final session = WordChainSession.fromMap(doc.id, data);
          final participants = _normalizeParticipants(
            session,
            userId: userId,
            partnerId: partnerId,
          );
          final jokers =
              _normalizeJokers(participants, session.jokersRemaining);
          final requiredSuffixLength =
              _suffixLengthForSession(session.mode, session.words.length);
          final turnSeconds =
              _turnSecondsForSession(session.mode, requiredSuffixLength);

          final readyUsers = List<String>.from(data['readyUsers'] ?? const []);
          final updates = <String, dynamic>{
            'participants': participants,
            'jokersRemaining': jokers,
            'requiredSuffixLength': requiredSuffixLength,
            'turnSeconds': turnSeconds,
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
                type: 'word_chain_partner_joined',
                title: 'Word Chain',
                body: 'Partnerin oyuna katildi. Tur baslayabilir.',
              );
            }
          }

          return;
        }
      }
    }

    final sessionRef = _sessionsRef().doc();
    final participants = [userId, partnerId];
    final requiredSuffixLength = _suffixLengthForSession(mode, 0);
    final turnSeconds = _turnSecondsForSession(mode, requiredSuffixLength);

    await sessionRef.set({
      'id': sessionRef.id,
      'coupleId': coupleId,
      'status': 'waiting',
      'mode': WordChainSession.modeToStorage(mode),
      'category': category,
      'words': <Map<String, dynamic>>[],
      'currentTurnUserId': userId,
      'readyUsers': [userId],
      'turnDeadline': null,
      'winnerUserId': null,
      'loserReason': null,
      'participants': participants,
      'requiredSuffixLength': requiredSuffixLength,
      'jokersRemaining': _defaultJokers(participants),
      'turnSeconds': turnSeconds,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _sendNotificationSafe(
      targetUserId: partnerId,
      fromUserId: userId,
      coupleId: coupleId,
      sessionId: sessionRef.id,
      type: 'word_chain_invite',
      title: 'Word Chain',
      body: 'Partnerin seni Word Chain oyununa davet ediyor.',
    );
  }

  @override
  Future<bool> startGame(String sessionId) async {
    return _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return false;

      final session = WordChainSession.fromMap(snapshot.id, snapshot.data()!);

      if (!session.active ||
          session.status != WordChainStatus.waiting ||
          session.readyUsers.length < 2) {
        return false;
      }

      final currentTurnUserId =
          session.currentTurnUserId ?? session.readyUsers.first;
      final participants = _normalizeParticipants(
        session,
        userId: currentTurnUserId,
      );
      final jokers = _normalizeJokers(participants, session.jokersRemaining);
      final requiredSuffixLength =
          _suffixLengthForSession(session.mode, session.words.length);
      final turnSeconds =
          _turnSecondsForSession(session.mode, requiredSuffixLength);

      transaction.update(ref, {
        'status': 'playing',
        'currentTurnUserId': currentTurnUserId,
        'participants': participants,
        'requiredSuffixLength': requiredSuffixLength,
        'jokersRemaining': jokers,
        'turnSeconds': turnSeconds,
        'turnDeadline': _deadlineFromNow(turnSeconds),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  @override
  Future<bool> submitWord({
    required String sessionId,
    required String userId,
    required String word,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return false;

      final session = WordChainSession.fromMap(snapshot.id, snapshot.data()!);
      final normalized = word.trim();

      if (!session.active ||
          session.status != WordChainStatus.playing ||
          session.currentTurnUserId != userId) {
        return false;
      }

      final validation = WordChainValidator.validate(normalized, session);
      if (validation != null) {
        final winnerId = session.partnerOf(userId);
        transaction.update(ref, {
          'status': 'gameover',
          'winnerUserId': winnerId,
          'loserReason': 'invalid_word',
          'turnDeadline': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return false;
      }

      final nextTurnUserId = session.partnerOf(userId) ?? userId;
      final updatedWords = [
        ...session.words.map((e) => e.toMap()),
        WordEntry(
          word: normalized,
          userId: userId,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ).toMap(),
      ];

      final newWordCount = updatedWords.length;
      final requiredSuffixLength =
          _suffixLengthForSession(session.mode, newWordCount);
      final turnSeconds =
          _turnSecondsForSession(session.mode, requiredSuffixLength);

      transaction.update(ref, {
        'words': updatedWords,
        'requiredSuffixLength': requiredSuffixLength,
        'turnSeconds': turnSeconds,
        'currentTurnUserId': nextTurnUserId,
        'turnDeadline': _deadlineFromNow(turnSeconds),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  @override
  Future<bool> useJoker({
    required String sessionId,
    required String userId,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return false;

      final session = WordChainSession.fromMap(snapshot.id, snapshot.data()!);
      if (!session.active || session.status != WordChainStatus.playing) {
        return false;
      }
      if (session.currentTurnUserId != userId) return false;

      final remaining = session.jokersRemaining[userId] ?? 0;
      if (remaining <= 0) return false;

      final nextTurnUserId = session.partnerOf(userId);
      if (nextTurnUserId == null || nextTurnUserId.isEmpty) return false;

      final participants = _normalizeParticipants(
        session,
        userId: userId,
        partnerId: nextTurnUserId,
      );
      final jokers = _normalizeJokers(participants, session.jokersRemaining);
      jokers[userId] = _normalizeJokerValue(remaining - 1);

      final requiredSuffixLength =
          _suffixLengthForSession(session.mode, session.words.length);
      final turnSeconds =
          _turnSecondsForSession(session.mode, requiredSuffixLength);

      transaction.update(ref, {
        'participants': participants,
        'jokersRemaining': jokers,
        'requiredSuffixLength': requiredSuffixLength,
        'turnSeconds': turnSeconds,
        'currentTurnUserId': nextTurnUserId,
        'turnDeadline': _deadlineFromNow(turnSeconds),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  @override
  Future<void> timeoutCurrentTurn(String sessionId) async {
    await _firestore.runTransaction((transaction) async {
      final ref = _sessionsRef().doc(sessionId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;

      final session = WordChainSession.fromMap(snapshot.id, snapshot.data()!);

      if (!session.active || session.status != WordChainStatus.playing) return;
      if (session.turnDeadline == null) return;
      if (DateTime.now().isBefore(session.turnDeadline!)) return;

      final loserUserId = session.currentTurnUserId;
      if (loserUserId == null) return;

      transaction.update(ref, {
        'status': 'gameover',
        'winnerUserId': session.partnerOf(loserUserId),
        'loserReason': 'timeout',
        'turnDeadline': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
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

      final session = WordChainSession.fromMap(snapshot.id, snapshot.data()!);

      if (!session.active) return;

      if (session.status == WordChainStatus.waiting ||
          session.status == WordChainStatus.playing) {
        transaction.update(ref, {
          'status': 'gameover',
          'winnerUserId': session.partnerOf(userId),
          'loserReason': 'left',
          'turnDeadline': null,
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
    required WordChainMode mode,
    String? category,
  }) async {
    final ref = _sessionsRef().doc(sessionId);

    String partnerId = '';
    String? coupleId;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;

      final session = WordChainSession.fromMap(snapshot.id, snapshot.data()!);
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

      final requiredSuffixLength = _suffixLengthForSession(mode, 0);
      final turnSeconds = _turnSecondsForSession(mode, requiredSuffixLength);

      transaction.update(ref, {
        'status': 'waiting',
        'mode': WordChainSession.modeToStorage(mode),
        'category': category,
        'words': <Map<String, dynamic>>[],
        'currentTurnUserId': userId,
        'readyUsers': [userId],
        'turnDeadline': null,
        'winnerUserId': null,
        'loserReason': null,
        'participants': participants,
        'requiredSuffixLength': requiredSuffixLength,
        'jokersRemaining': _defaultJokers(participants),
        'turnSeconds': turnSeconds,
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
        type: 'word_chain_invite',
        title: 'Word Chain',
        body: 'Partnerin Word Chain icin tekrar davet gonderdi.',
      );
    }
  }

  @override
  Stream<WordChainSession?> watchSession(String coupleId) {
    return _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;

      final sessions = snapshot.docs
          .map((doc) => WordChainSession.fromMap(doc.id, doc.data()))
          .where((s) => s.status != WordChainStatus.cancelled)
          .toList();

      if (sessions.isEmpty) return null;

      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      for (final session in sessions) {
        if (session.status == WordChainStatus.playing) return session;
      }
      for (final session in sessions) {
        if (session.status == WordChainStatus.waiting) return session;
      }

      return sessions.first;
    });
  }
}
