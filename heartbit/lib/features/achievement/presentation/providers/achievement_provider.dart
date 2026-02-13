
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/pet/presentation/providers/pet_provider.dart';
import 'package:heartbit/features/achievement/domain/entities/achievement.dart';
import 'package:heartbit/features/achievement/data/datasources/achievement_datasource.dart';

part 'achievement_provider.g.dart';

// --- Data Layer ---

@riverpod
AchievementDataSource achievementDataSource(AchievementDataSourceRef ref) {
  return AchievementDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

// --- Presentation Layer ---

/// Stream of unlocked achievements for the current couple
@riverpod
Stream<List<UnlockedAchievement>> unlockedAchievements(UnlockedAchievementsRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  
  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return const Stream.empty();
      return ref.watch(achievementDataSourceProvider).watchUnlockedAchievements(couple.id);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}

/// Combined view: All achievements with unlock status
@riverpod
class AchievementList extends _$AchievementList {
  @override
  List<AchievementWithStatus> build() {
    final unlockedAsync = ref.watch(unlockedAchievementsProvider);
    
    return unlockedAsync.when(
      data: (unlockedList) {
        final unlockedMap = {
          for (final u in unlockedList) u.achievementId: u
        };
        
        return Achievements.all.map((achievement) {
          final unlocked = unlockedMap[achievement.id];
          return AchievementWithStatus(
            achievement: achievement,
            isUnlocked: unlocked != null,
            unlockedAt: unlocked?.unlockedAt,
            isClaimed: unlocked?.isClaimed ?? false,
          );
        }).toList();
      },
      loading: () => Achievements.all.map((a) => AchievementWithStatus(
        achievement: a,
        isUnlocked: false,
      )).toList(),
      error: (_, __) => [],
    );
  }
}

/// Achievement with unlock status
class AchievementWithStatus {
  final Achievement achievement;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool isClaimed;

  AchievementWithStatus({
    required this.achievement,
    required this.isUnlocked,
    this.unlockedAt,
    this.isClaimed = false,
  });
}

/// Controller for achievement actions
@riverpod
class AchievementController extends _$AchievementController {
  @override
  FutureOr<void> build() {}

  /// Check and unlock achievements based on current state
  Future<void> checkAchievements({
    int? petLevel,
    int? streak,
    int? totalTasksCompleted,
    bool? hasPaired,
    bool? hasCreatedPet,
    int? moodDaysStreak,
  }) async {
    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) return;
    
    final coupleId = coupleAsync.value!.id;
    final dataSource = ref.read(achievementDataSourceProvider);
    
    // Pet achievements
    if (hasCreatedPet == true) {
      await _tryUnlock(dataSource, coupleId, 'first_egg');
    }
    
    if (petLevel != null) {
      if (petLevel >= 5) await _tryUnlock(dataSource, coupleId, 'first_evolution');
      if (petLevel >= 10) {
        await _tryUnlock(dataSource, coupleId, 'teen_stage');
        await _tryUnlock(dataSource, coupleId, 'pet_level_10');
      }
      if (petLevel >= 20) await _tryUnlock(dataSource, coupleId, 'pet_master');
    }
    
    // Streak achievements
    if (streak != null) {
      if (streak >= 3) await _tryUnlock(dataSource, coupleId, 'streak_3');
      if (streak >= 7) await _tryUnlock(dataSource, coupleId, 'streak_7');
      if (streak >= 30) await _tryUnlock(dataSource, coupleId, 'streak_30');
      if (streak >= 100) await _tryUnlock(dataSource, coupleId, 'streak_100');
    }
    
    // Social achievements
    if (hasPaired == true) {
      await _tryUnlock(dataSource, coupleId, 'first_pair');
    }
    
    // Task milestones
    if (totalTasksCompleted != null) {
      if (totalTasksCompleted >= 1) await _tryUnlock(dataSource, coupleId, 'first_task');
      if (totalTasksCompleted >= 50) await _tryUnlock(dataSource, coupleId, 'tasks_50');
      if (totalTasksCompleted >= 100) await _tryUnlock(dataSource, coupleId, 'tasks_100');
    }
    
    // Mood streak achievements
    if (moodDaysStreak != null) {
      if (moodDaysStreak >= 7) await _tryUnlock(dataSource, coupleId, 'mood_7_days');
    }
  }

  Future<void> _tryUnlock(AchievementDataSource ds, String coupleId, String achievementId) async {
    final isAlreadyUnlocked = await ds.isUnlocked(coupleId, achievementId);
    if (!isAlreadyUnlocked) {
      await ds.unlockAchievement(coupleId, achievementId);
    }
  }

  /// Claim XP reward for an achievement
  Future<void> claimReward(String achievementId) async {
    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) return;
    
    final coupleId = coupleAsync.value!.id;
    final achievement = Achievements.getById(achievementId);
    if (achievement == null) return;
    
    // Mark as claimed
    await ref.read(achievementDataSourceProvider).claimAchievement(coupleId, achievementId);
    
    // Add XP reward to pet
    await ref.read(petRepositoryProvider).addExperience(coupleId, achievement.xpReward.toDouble());
  }
}
