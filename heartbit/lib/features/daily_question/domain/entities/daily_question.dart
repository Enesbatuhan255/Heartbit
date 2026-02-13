import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_question.freezed.dart';
part 'daily_question.g.dart';

/// Daily question entity for couple Q&A feature
@freezed
class DailyQuestion with _$DailyQuestion {
  const DailyQuestion._();

  const factory DailyQuestion({
    required String id,              // Document ID (date: "2026-01-20")
    required String coupleId,
    required String questionId,      // "q_014" - for analytics, no repeats, premium
    required String questionText,
    required String date,            // UTC date string "yyyy-MM-dd"
    @Default(false) bool locked,     // true = no more changes allowed
    String? user1Answer,
    String? user2Answer,
    DateTime? user1AnsweredAt,
    DateTime? user2AnsweredAt,
    String? user1Reaction,           // 'heart', 'laugh', 'surprised'
    String? user2Reaction,
    @Default(false) bool xpClaimed,  // Base XP claimed
    @Default(false) bool syncXpClaimed, // Sync bonus XP claimed
  }) = _DailyQuestion;

  factory DailyQuestion.fromJson(Map<String, dynamic> json) =>
      _$DailyQuestionFromJson(json);

  /// Check if both users have answered
  bool get bothAnswered => user1Answer != null && user2Answer != null;

  /// Check if user1 has answered
  bool get user1Answered => user1Answer != null;

  /// Check if user2 has answered
  bool get user2Answered => user2Answer != null;

  /// Check if XP bonus can be claimed
  bool get canClaimXp => bothAnswered && !xpClaimed && !locked;
}
