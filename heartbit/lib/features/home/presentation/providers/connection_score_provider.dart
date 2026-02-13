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
  final currentStreak = couple?.currentStreak ?? 0;
  
  // Get mood status - check if mood was set today
  final moodAsync = ref.watch(currentMoodProvider);
  final hasMoodToday = moodAsync.valueOrNull != null;
  
  // TODO: These would need tracking in Firestore for accurate daily data
  // For now, using reasonable defaults based on what we can detect
  const playedDrawingToday = false; // Would need to track in couple doc
  const sentNudgeToday = false; // Would need to track in couple doc
  
  // Calculate the score
  return ConnectionScoreCalculator.calculate(
    todaysQuestion: todaysQuestion,
    playedDrawingToday: playedDrawingToday,
    sentNudgeToday: sentNudgeToday,
    setMoodToday: hasMoodToday,
    currentStreak: currentStreak,
    yesterdayScore: null, // TODO: Store and retrieve yesterday's score
  );
});
