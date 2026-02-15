
import '../entities/daily_task.dart';

abstract class TaskRepository {
  /// Get today's tasks for a user (with completion status)
  Stream<List<DailyTask>> watchTodaysTasks(String userId);
  
  /// Mark a task as completed and return XP reward
  Future<int> completeTask(String userId, String taskId);
  
  /// Reset all tasks for a new day (called automatically or manually)
  Future<void> resetDailyTasks(String userId);
  
  /// Watch the current streak count
  Stream<int> watchStreak(String coupleId);
  
  /// Update streak when tasks are completed
  Future<void> updateStreak(String coupleId, {required bool allTasksCompleted});
  
  /// Snapchat-style: Increment streak on any daily interaction
  Future<void> incrementStreakOnInteraction(String coupleId);
}
