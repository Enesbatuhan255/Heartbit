
import '../../domain/entities/daily_task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl({required TaskRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Stream<List<DailyTask>> watchTodaysTasks(String userId) {
    return _remoteDataSource.watchTodaysTasks(userId);
  }

  @override
  Future<int> completeTask(String userId, String taskId) {
    return _remoteDataSource.completeTask(userId, taskId);
  }

  @override
  Future<void> resetDailyTasks(String userId) {
    return _remoteDataSource.resetDailyTasks(userId);
  }

  @override
  Stream<int> watchStreak(String coupleId) {
    return _remoteDataSource.watchStreak(coupleId);
  }

  @override
  Future<void> updateStreak(String coupleId, {required bool allTasksCompleted}) {
    return _remoteDataSource.updateStreak(coupleId, allTasksCompleted: allTasksCompleted);
  }

  @override
  Future<void> incrementStreakOnInteraction(String coupleId) {
    return _remoteDataSource.incrementStreakOnInteraction(coupleId);
  }
}
