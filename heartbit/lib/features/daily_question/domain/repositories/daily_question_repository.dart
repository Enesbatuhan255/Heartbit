import '../entities/daily_question.dart';

/// Abstract repository for Daily Question feature
abstract class DailyQuestionRepository {
  /// Watch today's question for a couple (real-time stream)
  Stream<DailyQuestion?> watchTodaysQuestion(String coupleId);

  /// Get or create today's question (idempotent)
  Future<DailyQuestion> getOrCreateTodaysQuestion(String coupleId);

  /// Submit an answer for a user
  /// Throws [LockedQuestionException] if question is locked
  Future<void> submitAnswer({
    required String coupleId,
    required String date,
    required String userId,
    required bool isUser1,
    required String answer,
  });

  /// Claim bonus XP using Firestore transaction (prevents duplication)
  /// Returns true if XP was claimed, false if already claimed or not eligible
  Future<bool> claimBonusXpTransaction({
    required String coupleId,
    required String date,
  });

  /// Submit emoji reaction to partner's answer
  Future<void> submitReaction({
    required String coupleId,
    required String date,
    required String userId,
    required bool isUser1,
    required String reaction,
  });

  /// Get past questions for archive (excluding today)
  Future<List<DailyQuestion>> getPastQuestions({
    required String coupleId,
    int limit = 30,
  });

  /// Claim sync bonus XP (if not already claimed)
  Future<bool> claimSyncBonusXpTransaction({
    required String coupleId,
    required String date,
    required int xpAmount,
  });
}

/// Exception thrown when trying to modify a locked question
class LockedQuestionException implements Exception {
  final String message;
  LockedQuestionException([this.message = 'Question is locked']);

  @override
  String toString() => 'LockedQuestionException: $message';
}
