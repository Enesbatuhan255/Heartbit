import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../../domain/entities/daily_question.dart';
import '../../domain/entities/question_bank.dart';
import '../../domain/repositories/daily_question_repository.dart';

/// Remote datasource for Daily Question feature
abstract class DailyQuestionRemoteDataSource {
  /// Get today's UTC date key
  String getTodayKey();

  /// Watch today's question
  Stream<DailyQuestion?> watchTodaysQuestion(String coupleId);

  /// Get or create today's question
  Future<DailyQuestion> getOrCreateTodaysQuestion(String coupleId);

  /// Submit answer
  Future<void> submitAnswer({
    required String coupleId,
    required String date,
    required bool isUser1,
    required String answer,
  });

  /// Claim bonus XP via transaction
  Future<bool> claimBonusXpTransaction({
    required String coupleId,
    required String date,
  });

  /// Submit emoji reaction to partner's answer
  Future<void> submitReaction({
    required String coupleId,
    required String date,
    required bool isUser1,
    required String reaction, // 'heart', 'laugh', 'surprised'
  });

  /// Claim sync bonus XP via transaction
  Future<bool> claimSyncBonusXpTransaction({
    required String coupleId,
    required String date,
    required int xpAmount,
  });

  /// Get past questions for archive (excluding today)
  Future<List<DailyQuestion>> getPastQuestions({
    required String coupleId,
    int limit = 30,
  });
}

/// Firestore implementation
class DailyQuestionRemoteDataSourceImpl implements DailyQuestionRemoteDataSource {
  final FirebaseFirestore _firestore;

  DailyQuestionRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Collection reference for daily questions
  CollectionReference<Map<String, dynamic>> _questionsRef(String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('daily_questions');
  }

  @override
  String getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
  }

  @override
  Stream<DailyQuestion?> watchTodaysQuestion(String coupleId) {
    final todayKey = getTodayKey();
    return _questionsRef(coupleId)
        .doc(todayKey)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return _fromFirestore(snapshot.data()!);
    });
  }

  @override
  Future<DailyQuestion> getOrCreateTodaysQuestion(String coupleId) async {
    final todayKey = getTodayKey();
    final docRef = _questionsRef(coupleId).doc(todayKey);

    final snapshot = await docRef.get();

    if (snapshot.exists && snapshot.data() != null) {
      return _fromFirestore(snapshot.data()!);
    }

    // Create new question for today (Randomly selected)
    final questions = QuestionBank.questions;
    final randomIndex = Random().nextInt(questions.length);
    final question = questions[randomIndex];
    final newQuestion = DailyQuestion(
      id: todayKey,
      coupleId: coupleId,
      questionId: question.id,
      questionText: question.text,
      date: todayKey,
      locked: false,
      xpClaimed: false,
    );

    await docRef.set(_toFirestore(newQuestion));
    
    return newQuestion;
  }

  @override
  Future<void> submitAnswer({
    required String coupleId,
    required String date,
    required bool isUser1,
    required String answer,
  }) async {
    return _firestore.runTransaction((tx) async {
      final questionRef = _questionsRef(coupleId).doc(date);
      
      // ===== ALL READS FIRST =====
      final questionSnap = await tx.get(questionRef);

      if (!questionSnap.exists) {
        throw Exception('Question not found for date: $date');
      }

      final qData = questionSnap.data()!;
      if (qData['locked'] == true) {
        throw LockedQuestionException('Cannot submit answer: question is locked');
      }

      // ===== ALL WRITES AFTER READS =====
      final updateData = <String, dynamic>{};
      if (isUser1) {
        updateData['user1Answer'] = answer;
        updateData['user1AnsweredAt'] = FieldValue.serverTimestamp();
      } else {
        updateData['user2Answer'] = answer;
        updateData['user2AnsweredAt'] = FieldValue.serverTimestamp();
      }

      tx.update(questionRef, updateData);
    });
  }

  @override
  Future<bool> claimBonusXpTransaction({
    required String coupleId,
    required String date,
  }) async {
    return _firestore.runTransaction<bool>((tx) async {
      final docRef = _questionsRef(coupleId).doc(date);
      final snapshot = await tx.get(docRef);

      if (!snapshot.exists) return false;

      final data = snapshot.data()!;

      // Check conditions
      if (data['xpClaimed'] == true) return false;  // Already claimed
      if (data['locked'] == true) return false;     // Day locked
      if (data['user1Answer'] == null || data['user2Answer'] == null) {
        return false; // Both haven't answered
      }

      // Give XP to pet
      final petRef = _firestore.collection('pets').doc(coupleId);
      final petSnap = await tx.get(petRef);

      if (petSnap.exists) {
        final currentXp = (petSnap.data()?['totalXp'] ?? 0.0) as num;
        final currentExp = (petSnap.data()?['experience'] ?? 0.0) as num;
        tx.update(petRef, {
          'totalXp': currentXp + 25.0,
          'experience': currentExp + 25.0,
        });
      }

      // Mark XP as claimed
      tx.update(docRef, {'xpClaimed': true});

      return true;
    });
  }

  @override
  Future<void> submitReaction({
    required String coupleId,
    required String date,
    required bool isUser1,
    required String reaction,
  }) async {
    final docRef = _questionsRef(coupleId).doc(date);
    final updateData = <String, dynamic>{};
    
    if (isUser1) {
      updateData['user1Reaction'] = reaction;
    } else {
      updateData['user2Reaction'] = reaction;
    }

    await docRef.update(updateData);
  }

  @override
  Future<List<DailyQuestion>> getPastQuestions({
    required String coupleId,
    int limit = 30,
  }) async {
    final todayKey = getTodayKey();
    
    // Query past questions (before today), ordered by date descending
    final snapshot = await _questionsRef(coupleId)
        .where('date', isLessThan: todayKey)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => _fromFirestore(doc.data()))
        .where((q) => q.bothAnswered) // Only show completed questions
        .toList();
  }

  @override
  Future<bool> claimSyncBonusXpTransaction({
    required String coupleId,
    required String date,
    required int xpAmount,
  }) async {
    return _firestore.runTransaction<bool>((tx) async {
      final docRef = _questionsRef(coupleId).doc(date);
      final snapshot = await tx.get(docRef);

      if (!snapshot.exists) return false;

      final data = snapshot.data()!;

      // Check if already claimed
      if (data['syncXpClaimed'] == true) return false;

      // Give XP to pet
      final petRef = _firestore.collection('pets').doc(coupleId);
      final petSnap = await tx.get(petRef);

      if (petSnap.exists) {
        final currentXp = (petSnap.data()?['totalXp'] ?? 0.0) as num;
        final currentExp = (petSnap.data()?['experience'] ?? 0.0) as num;
        tx.update(petRef, {
          'totalXp': currentXp + xpAmount,
          'experience': currentExp + xpAmount,
        });
      }

      // Mark Sync XP as claimed
      tx.update(docRef, {'syncXpClaimed': true});

      return true;
    });
  }

  /// Convert Firestore data to DailyQuestion
  DailyQuestion _fromFirestore(Map<String, dynamic> data) {
    return DailyQuestion(
      id: data['id'] as String,
      coupleId: data['coupleId'] as String,
      questionId: data['questionId'] as String,
      questionText: data['questionText'] as String,
      date: data['date'] as String,
      locked: data['locked'] as bool? ?? false,
      user1Answer: data['user1Answer'] as String?,
      user2Answer: data['user2Answer'] as String?,
      user1AnsweredAt: (data['user1AnsweredAt'] as Timestamp?)?.toDate(),
      user2AnsweredAt: (data['user2AnsweredAt'] as Timestamp?)?.toDate(),
      user1Reaction: data['user1Reaction'] as String?,
      user2Reaction: data['user2Reaction'] as String?,
      xpClaimed: data['xpClaimed'] as bool? ?? false,
      syncXpClaimed: data['syncXpClaimed'] as bool? ?? false,
    );
  }

  /// Convert DailyQuestion to Firestore data
  Map<String, dynamic> _toFirestore(DailyQuestion question) {
    return {
      'id': question.id,
      'coupleId': question.coupleId,
      'questionId': question.questionId,
      'questionText': question.questionText,
      'date': question.date,
      'locked': question.locked,
      'user1Answer': question.user1Answer,
      'user2Answer': question.user2Answer,
      'user1AnsweredAt': question.user1AnsweredAt != null
          ? Timestamp.fromDate(question.user1AnsweredAt!)
          : null,
      'user2AnsweredAt': question.user2AnsweredAt != null
          ? Timestamp.fromDate(question.user2AnsweredAt!)
          : null,
      'user1Reaction': question.user1Reaction,
      'user2Reaction': question.user2Reaction,
      'xpClaimed': question.xpClaimed,
      'syncXpClaimed': question.syncXpClaimed,
    };
  }
}
