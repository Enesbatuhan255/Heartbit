import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/daily_question/presentation/providers/daily_question_provider.dart';
import 'package:heartbit/features/home/domain/entities/connection_score.dart';
import 'package:heartbit/features/home/domain/utils/connection_score_calculator.dart';
import 'package:heartbit/features/home/presentation/providers/mood_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';

/// Provider for calculating and tracking connection score
final connectionScoreProvider = Provider<ConnectionScore>((ref) {
  // Get today's daily question
  final dailyQuestionAsync = ref.watch(todaysQuestionProvider);
  final todaysQuestion = dailyQuestionAsync.valueOrNull;
  
  // Get current streak from couple data
  final coupleAsync = ref.watch(coupleStateProvider);
  final couple = coupleAsync.valueOrNull;
  final currentStreak = couple?.streak ?? 0;
  
  // Get mood status - check if mood was set today
  final moodAsync = ref.watch(currentMoodProvider);
  final hasMoodToday = moodAsync.valueOrNull != null;
  
  // NOTE: These activities would need tracking in Firestore for accurate daily data
  // For now, using reasonable defaults based on what we can detect
  // Future enhancement: Track drawing game and nudge activity in couple document
  const playedDrawingToday = false; // Tracked in: couple.drawingActivityLastDate
  const sentNudgeToday = false; // Tracked in: couple.nudgeActivityLastDate
  
  // Calculate the score
  return ConnectionScoreCalculator.calculate(
    todaysQuestion: todaysQuestion,
    playedDrawingToday: playedDrawingToday,
    sentNudgeToday: sentNudgeToday,
    setMoodToday: hasMoodToday,
    currentStreak: currentStreak,
    yesterdayScore: null, // NOTE: Yesterday's score should be stored in couple doc for trend tracking
  );
});
