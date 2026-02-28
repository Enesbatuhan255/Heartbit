import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/achievement/presentation/providers/achievement_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/user/presentation/providers/user_provider.dart';
import 'package:heartbit/features/home/domain/entities/mood.dart';
import 'package:heartbit/features/home/data/datasources/mood_remote_datasource.dart';

part 'mood_provider.g.dart';

// --- Data Layer ---
@riverpod
MoodRemoteDataSource moodRemoteDataSource(MoodRemoteDataSourceRef ref) {
  return MoodRemoteDataSource(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

// --- Presentation Layer ---

/// Stream of today's mood from Firestore (persisted across app restarts)
@riverpod
Stream<Mood?> currentMood(CurrentMoodRef ref) {
  final userId = ref.watch(authUserIdProvider);
  if (userId == null) return const Stream.empty();
  
  return ref.watch(moodRemoteDataSourceProvider).watchTodaysMood(userId);
}

/// Stream of partner's mood
@riverpod
Stream<Mood?> partnerMood(PartnerMoodRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  
  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return const Stream.empty();
      
      final userId = ref.read(authUserIdProvider);
      final partnerId = couple.user1Id == userId ? couple.user2Id : couple.user1Id;
      
      return ref.watch(moodRemoteDataSourceProvider).watchTodaysMood(partnerId);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}

/// Controller for mood actions
@riverpod
class MoodController extends _$MoodController {
  @override
  FutureOr<void> build() {}

  /// Set today's mood (persisted to Firestore)
  Future<void> setMood(Mood mood) async {
    final userId = ref.read(authUserIdProvider);
    if (userId == null) return;

    state = const AsyncLoading();
    try {
      // Save mood to Firestore
      await ref.read(moodRemoteDataSourceProvider).setTodaysMood(userId, mood);
      
      // Check mood streak for achievements
      final consecutiveDays = await ref.read(moodRemoteDataSourceProvider).getConsecutiveMoodDays(userId);
      if (consecutiveDays >= 7) {
        ref.read(achievementControllerProvider.notifier).checkAchievements(
          moodDaysStreak: consecutiveDays,
        );
      }
      
      // Send partner notification
      await _sendMoodNotification(mood);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Send mood notification to partner
  Future<void> _sendMoodNotification(Mood mood) async {
    try {
      final userId = ref.read(authUserIdProvider);
      if (userId == null) return;

      // Get current user profile for display name
      final userProfile = await ref.read(userRepositoryProvider).getUser(userId);
      final userName = userProfile?.displayName ?? 'Your partner';

      // Get couple to find partner
      final couple = ref.read(coupleStateProvider).valueOrNull;
      if (couple == null) return;

      final partnerId = couple.user1Id == userId ? couple.user2Id : couple.user1Id;
      if (partnerId == null || partnerId.isEmpty) return;

      // Create notification document for partner
      final firestore = ref.read(firebaseFirestoreProvider);
      await firestore
          .collection('users')
          .doc(partnerId)
          .collection('notifications')
          .add({
        'type': 'mood_update',
        'title': '$userName is feeling ${mood.label} ${mood.emoji}',
        'body': 'Tap to see how they\'re doing today',
        'senderId': userId,
        'mood': mood.name,
        'moodEmoji': mood.emoji,
        'moodLabel': mood.label,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Do not write partner's /users doc directly; Firestore rules only allow
      // self-updates (except limited pairing fields).
    } catch (e) {
      // Silently fail - notification is not critical
      print('Failed to send mood notification: $e');
    }
  }
}
