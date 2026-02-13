
import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_task.freezed.dart';
part 'daily_task.g.dart';

/// Task types for categorization and future filtering
enum TaskType {
  mood,    // Mood selection tasks
  pet,     // Pet interaction tasks
  social,  // Partner interaction tasks
}

@freezed
class DailyTask with _$DailyTask {
  const factory DailyTask({
    required String id,
    required String title,
    required String emoji,
    required int rewardXp,
    required TaskType type,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
  }) = _DailyTask;

  factory DailyTask.fromJson(Map<String, dynamic> json) => _$DailyTaskFromJson(json);
}

/// Predefined MVP tasks (hardcoded)
class DefaultTasks {
  static List<DailyTask> get all => [
    const DailyTask(
      id: 'mood_select',
      title: 'Mood seç',
      emoji: '🧠',
      rewardXp: 10,
      type: TaskType.mood,
    ),
    const DailyTask(
      id: 'pet_visit',
      title: "Pet'i ziyaret et",
      emoji: '🐣',
      rewardXp: 5,
      type: TaskType.pet,
    ),
    const DailyTask(
      id: 'partner_message',
      title: 'Partnerine mesaj at',
      emoji: '💬',
      rewardXp: 15,
      type: TaskType.social,
    ),
  ];
}
