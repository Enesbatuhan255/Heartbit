import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/daily_question/domain/entities/daily_question.dart';
import 'package:heartbit/features/daily_question/domain/repositories/daily_question_repository.dart';
import 'package:heartbit/features/daily_question/data/datasources/daily_question_remote_datasource.dart';
import 'package:heartbit/features/daily_question/data/repositories/daily_question_repository_impl.dart';
import 'package:heartbit/features/task/presentation/providers/task_provider.dart';
import 'package:heartbit/features/egg/presentation/providers/egg_provider.dart';

part 'daily_question_provider.g.dart';

// --- Data Layer Providers ---

@riverpod
DailyQuestionRemoteDataSource dailyQuestionRemoteDataSource(
    DailyQuestionRemoteDataSourceRef ref) {
  return DailyQuestionRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
DailyQuestionRepository dailyQuestionRepository(DailyQuestionRepositoryRef ref) {
  return DailyQuestionRepositoryImpl(
    remoteDataSource: ref.watch(dailyQuestionRemoteDataSourceProvider),
  );
}

// --- Presentation Layer Providers ---

/// Stream of today's question for the current couple
@riverpod
Stream<DailyQuestion?> todaysQuestion(TodaysQuestionRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);

  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return Stream.value(null);
      return ref.watch(dailyQuestionRepositoryProvider)
          .watchTodaysQuestion(couple.id);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
}

/// Fetch past questions for archive screen
@riverpod
Future<List<DailyQuestion>> pastQuestions(PastQuestionsRef ref) async {
  final coupleAsync = ref.watch(coupleStateProvider);
  final couple = coupleAsync.valueOrNull;
  
  if (couple == null) return [];
  
  return ref.watch(dailyQuestionRepositoryProvider)
      .getPastQuestions(coupleId: couple.id, limit: 30);
}

/// Controller for Daily Question actions
@riverpod
class DailyQuestionController extends _$DailyQuestionController {
  @override
  FutureOr<void> build() {
    // Initial state - nothing
  }

  /// Initialize today's question (call on app start/screen load)
  Future<void> initTodaysQuestion() async {
    final coupleAsync = ref.read(coupleStateProvider);
    final couple = coupleAsync.valueOrNull;
    if (couple == null) return;

    state = const AsyncLoading();
    try {
      await ref.read(dailyQuestionRepositoryProvider)
          .getOrCreateTodaysQuestion(couple.id);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Submit answer for current user
  Future<bool> submitAnswer(String answer) async {
    final coupleAsync = ref.read(coupleStateProvider);
    final couple = coupleAsync.valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (couple == null || userId == null) {
      state = AsyncError('Not paired or not logged in', StackTrace.current);
      return false;
    }

    final isUser1 = couple.user1Id == userId;
    final dateKey = ref.read(dailyQuestionRemoteDataSourceProvider).getTodayKey();

    state = const AsyncLoading();
    try {
      await ref.read(dailyQuestionRepositoryProvider).submitAnswer(
        coupleId: couple.id,
        date: dateKey,
        userId: userId,
        isUser1: isUser1,
        answer: answer,
      );

      // After submitting, try to claim XP (will only succeed if both answered)
      await _tryClaimBonusXp(couple.id, dateKey);
      
      // ADDED: Individual effort heat
      await ref.read(eggRepositoryProvider).incrementWarmth(couple.id, 10);

      // ADDED: Snapchat-style streak increment on interaction
      await ref.read(taskRepositoryProvider).incrementStreakOnInteraction(couple.id);

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Try to claim bonus XP (called after answer submission)
  Future<bool> _tryClaimBonusXp(String coupleId, String date) async {
    try {
      final claimed = await ref.read(dailyQuestionRepositoryProvider)
          .claimBonusXpTransaction(coupleId: coupleId, date: date);
      if (claimed) {
        print('DEBUG: Daily Question bonus XP claimed! (+25 XP)');
      }
      return claimed;
    } catch (e) {
      print('DEBUG: Failed to claim bonus XP: $e');
      return false;
    }
  }

  /// Submit emoji reaction to partner's answer
  Future<bool> submitReaction(String reaction) async {
    final coupleAsync = ref.read(coupleStateProvider);
    final couple = coupleAsync.valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (couple == null || userId == null) {
      return false;
    }

    final isUser1 = couple.user1Id == userId;
    final dateKey = ref.read(dailyQuestionRemoteDataSourceProvider).getTodayKey();

    try {
      await ref.read(dailyQuestionRepositoryProvider).submitReaction(
        coupleId: couple.id,
        date: dateKey,
        userId: userId,
        isUser1: isUser1,
        reaction: reaction,
      );
      
      // ADDED: Snapchat-style streak increment on interaction
      await ref.read(taskRepositoryProvider).incrementStreakOnInteraction(couple.id);
      
      return true;
    } catch (e) {
      print('DEBUG: Failed to submit reaction: $e');
      return false;
    }
  }

  /// Claim sync bonus XP (called when celebration triggers)
  Future<bool> claimSyncBonus(int xpAmount) async {
    final coupleAsync = ref.read(coupleStateProvider);
    final couple = coupleAsync.valueOrNull;
    
    if (couple == null) return false;
    
    final dateKey = ref.read(dailyQuestionRemoteDataSourceProvider).getTodayKey();
    
    try {
      final claimed = await ref.read(dailyQuestionRepositoryProvider)
          .claimSyncBonusXpTransaction(
            coupleId: couple.id,
            date: dateKey,
            xpAmount: xpAmount,
          );
          
      if (claimed) {
        print('DEBUG: Sync bonus XP claimed! (+$xpAmount XP)');
        // ADDED: Significant warmth boost for syncing!
        await ref.read(eggRepositoryProvider).incrementWarmth(couple.id, 50);
      }
      return claimed;
    } catch (e) {
      print('DEBUG: Failed to claim sync bonus XP: $e');
      return false;
    }
  }
}
