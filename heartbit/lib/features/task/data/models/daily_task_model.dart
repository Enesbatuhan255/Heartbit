
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/daily_task.dart';

class DailyTaskModel {
  static DailyTask fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DailyTask(
      id: doc.id,
      title: data['title'] as String,
      emoji: data['emoji'] as String,
      rewardXp: (data['rewardXp'] as num).toInt(),
      type: TaskType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TaskType.mood,
      ),
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> toMap(DailyTask task) {
    return {
      'title': task.title,
      'emoji': task.emoji,
      'rewardXp': task.rewardXp,
      'type': task.type.name,
      'isCompleted': task.isCompleted,
      'completedAt': task.completedAt != null 
          ? Timestamp.fromDate(task.completedAt!) 
          : null,
    };
  }
}
