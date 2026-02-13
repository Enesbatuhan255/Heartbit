import 'package:heartbit/features/daily_question/domain/entities/daily_question.dart';
import 'package:heartbit/features/home/domain/entities/connection_score.dart';

/// Calculates the daily connection score based on couple activities
class ConnectionScoreCalculator {
  /// Calculate today's connection score
  /// 
  /// Points breakdown:
  /// - Daily Question answered (each user): +15 per user (max 30)
  /// - Both answered daily question: +20 bonus
  /// - Drawing game played today: +20
  /// - Nudge sent today: +10
  /// - Mood set today: +10
  /// - Streak bonus: +2 per streak day (max 10 for 5 days)
  static ConnectionScore calculate({
    DailyQuestion? todaysQuestion,
    bool playedDrawingToday = false,
    bool sentNudgeToday = false,
    bool setMoodToday = false,
    int currentStreak = 0,
    int? yesterdayScore,
  }) {
    final breakdown = <String, int>{};
    int totalScore = 0;
    
    // Daily Question points
    if (todaysQuestion != null) {
      int questionPoints = 0;
      
      // Points for each answer
      if (todaysQuestion.user1Answer != null) {
        questionPoints += 15;
      }
      if (todaysQuestion.user2Answer != null) {
        questionPoints += 15;
      }
      
      // Bonus for both answering
      if (todaysQuestion.bothAnswered) {
        questionPoints += 20;
      }
      
      if (questionPoints > 0) {
        breakdown['daily_question'] = questionPoints;
        totalScore += questionPoints;
      }
    }
    
    // Drawing game points
    if (playedDrawingToday) {
      breakdown['drawing_game'] = 20;
      totalScore += 20;
    }
    
    // Nudge points
    if (sentNudgeToday) {
      breakdown['nudge'] = 10;
      totalScore += 10;
    }
    
    // Mood points
    if (setMoodToday) {
      breakdown['mood'] = 10;
      totalScore += 10;
    }
    
    // Streak bonus (max 5 days = 10 points)
    if (currentStreak > 0) {
      final streakBonus = (currentStreak.clamp(0, 5)) * 2;
      breakdown['streak'] = streakBonus;
      totalScore += streakBonus;
    }
    
    // Cap at 100
    totalScore = totalScore.clamp(0, 100);
    
    return ConnectionScore(
      todayScore: totalScore,
      yesterdayScore: yesterdayScore,
      breakdown: breakdown,
    );
  }
}
