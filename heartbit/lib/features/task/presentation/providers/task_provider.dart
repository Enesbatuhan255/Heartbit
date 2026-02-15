
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/pet/presentation/providers/pet_provider.dart';
import 'package:heartbit/features/achievement/presentation/providers/achievement_provider.dart';
import 'package:heartbit/features/task/domain/entities/daily_task.dart';
import 'package:heartbit/features/task/domain/repositories/task_repository.dart';
import 'package:heartbit/features/task/data/datasources/task_remote_datasource.dart';
import 'package:heartbit/features/task/data/repositories/task_repository_impl.dart';

part 'task_provider.g.dart';

// --- Data Layer Providers ---

@riverpod
TaskRemoteDataSource taskRemoteDataSource(TaskRemoteDataSourceRef ref) {
  return TaskRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  return TaskRepositoryImpl(
    remoteDataSource: ref.watch(taskRemoteDataSourceProvider),
  );
}

// --- Presentation Layer Providers ---

@riverpod
Stream<List<DailyTask>> dailyTasks(DailyTasksRef ref) {
  final userId = ref.watch(authUserIdProvider);
  if (userId == null) return const Stream.empty();
  
  return ref.watch(taskRepositoryProvider).watchTodaysTasks(userId);
}

@riverpod
Stream<int> streak(StreakRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  
  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return const Stream.empty();
      return ref.watch(taskRepositoryProvider).watchStreak(couple.id);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}

@riverpod
class TaskController extends _$TaskController {
  @override
  FutureOr<void> build() {
    // Nothing to initialize
  }

  /// Complete a task and add XP to the pet
  Future<void> completeTask(String taskId) async {
    final userId = ref.read(authUserIdProvider);
    if (userId == null) return;

    state = const AsyncLoading();
    
    try {
      // 1. Mark task as completed and get XP reward
      final xpEarned = await ref.read(taskRepositoryProvider).completeTask(userId, taskId);
      
      if (xpEarned > 0) {
        // 2. Add XP to Pet (Task → PetXP → Level flow)
        final coupleAsync = ref.read(coupleStateProvider);
        if (coupleAsync.hasValue && coupleAsync.value != null) {
          final coupleId = coupleAsync.value!.id;
          await ref.read(petRepositoryProvider).addExperience(coupleId, xpEarned.toDouble());
          
          // 3. Snapchat-style: Increment streak on ANY task completion (interaction)
          await ref.read(taskRepositoryProvider).incrementStreakOnInteraction(coupleId);
          
          // 4. Check streak achievements after increment
          final streakAsync = ref.read(streakProvider);
          final petAsync = ref.read(petStateProvider);
          
          ref.read(achievementControllerProvider.notifier).checkAchievements(
            streak: streakAsync.valueOrNull,
            petLevel: petAsync.valueOrNull?.level,
          );
          
          // 5. Increment total tasks counter and check achievements with REAL count
          final totalTasks = await ref.read(taskRemoteDataSourceProvider).incrementTotalTasksCompleted(userId);
          ref.read(achievementControllerProvider.notifier).checkAchievements(
            totalTasksCompleted: totalTasks,
          );
        }
      }
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
