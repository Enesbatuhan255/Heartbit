
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/daily_task.dart';
import '../models/daily_task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<DailyTask>> watchTodaysTasks(String userId);
  Future<int> completeTask(String userId, String taskId);
  Future<void> resetDailyTasks(String userId);
  Future<void> initializeDailyTasks(String userId);
  Stream<int> watchStreak(String coupleId);
  Future<void> updateStreak(String coupleId, {required bool allTasksCompleted});
  
  /// Snapchat-style: Increment streak on any daily interaction
  Future<void> incrementStreakOnInteraction(String coupleId);
  
  /// Increment and return total tasks completed (all-time counter)
  Future<int> incrementTotalTasksCompleted(String userId);
  
  /// Watch total tasks completed count
  Stream<int> watchTotalTasksCompleted(String userId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('daily_tasks');

  DocumentReference<Map<String, dynamic>> _coupleDoc(String coupleId) =>
      _firestore.collection('couples').doc(coupleId);

  @override
  Stream<List<DailyTask>> watchTodaysTasks(String userId) {
    return _tasksCollection(userId).snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        // Initialize tasks for new users
        await initializeDailyTasks(userId);
        return DefaultTasks.all;
      }
      
      final tasks = snapshot.docs.map((doc) => DailyTaskModel.fromDocument(doc)).toList();
      
      // Check if any completed task is from a previous day → auto reset
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      
      bool needsReset = false;
      for (final task in tasks) {
        if (task.isCompleted && task.completedAt != null) {
          final completedDate = DateTime.utc(
            task.completedAt!.year,
            task.completedAt!.month,
            task.completedAt!.day,
          );
          if (completedDate.isBefore(today)) {
            needsReset = true;
            break;
          }
        }
      }
      
      if (needsReset) {
        await resetDailyTasks(userId);
        // Return reset tasks (all incomplete)
        return tasks.map((t) => t.copyWith(isCompleted: false, completedAt: null)).toList();
      }
      
      return tasks;
    });
  }

  @override
  Future<int> completeTask(String userId, String taskId) async {
    final docRef = _tasksCollection(userId).doc(taskId);
    
    // Use transaction to prevent race conditions (double XP)
    return await _firestore.runTransaction<int>((transaction) async {
      final doc = await transaction.get(docRef);
      
      int rewardXp = 0;
      
      if (!doc.exists) {
        // Task doesn't exist in Firestore yet, find from defaults
        final defaultTask = DefaultTasks.all.firstWhere(
          (t) => t.id == taskId,
          orElse: () => throw Exception('Task not found: $taskId'),
        );
        
        rewardXp = defaultTask.rewardXp;
        
        // Create the task document with completed status
        transaction.set(docRef, DailyTaskModel.toMap(defaultTask.copyWith(
          isCompleted: true,
          completedAt: DateTime.now().toUtc(),
        )));
      } else {
        // Task exists - check if already completed TODAY
        final data = doc.data()!;
        final isCompleted = data['isCompleted'] as bool? ?? false;
        
        if (isCompleted) {
          // Check if completed today or previous day
          final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
          if (completedAt != null) {
            final now = DateTime.now().toUtc();
            final today = DateTime.utc(now.year, now.month, now.day);
            final completedDate = DateTime.utc(completedAt.year, completedAt.month, completedAt.day);
            
            if (completedDate == today) {
              return 0; // Already completed today, no XP
            }
          } else {
            return 0; // isCompleted but no date - treat as completed
          }
        }
        
        rewardXp = (data['rewardXp'] as num?)?.toInt() ?? 10;
        
        transaction.update(docRef, {
          'isCompleted': true,
          'completedAt': Timestamp.fromDate(DateTime.now().toUtc()),
        });
      }
      
      return rewardXp;
    });
  }

  @override
  Future<void> resetDailyTasks(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _tasksCollection(userId).get();
    
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isCompleted': false,
        'completedAt': null,
      });
    }
    
    await batch.commit();
  }

  @override
  Future<void> initializeDailyTasks(String userId) async {
    final batch = _firestore.batch();
    
    for (final task in DefaultTasks.all) {
      final docRef = _tasksCollection(userId).doc(task.id);
      batch.set(docRef, DailyTaskModel.toMap(task), SetOptions(merge: true));
    }
    
    await batch.commit();
  }

  @override
  Stream<int> watchStreak(String coupleId) {
    return _coupleDoc(coupleId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return 0;
      
      final data = doc.data()!;
      final currentStreak = (data['streak'] as num?)?.toInt() ?? 0;
      final lastStreakDate = (data['lastStreakDate'] as Timestamp?)?.toDate();
      
      if (currentStreak == 0 || lastStreakDate == null) return 0;
      
      // Validate streak is still valid using UTC
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final lastDate = DateTime.utc(lastStreakDate.year, lastStreakDate.month, lastStreakDate.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      // If lastStreakDate is today or yesterday, streak is valid
      if (lastDate == today || lastDate == yesterday) {
        return currentStreak;
      }
      
      // Streak is broken (more than 1 day gap) - reset it
      await _resetStreakIfBroken(coupleId);
      return 0;
    });
  }

  /// Resets streak to 0 if it's been more than 1 day since last update
  Future<void> _resetStreakIfBroken(String coupleId) async {
    final docRef = _coupleDoc(coupleId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      
      final lastStreakDate = (snapshot.data()?['lastStreakDate'] as Timestamp?)?.toDate();
      if (lastStreakDate == null) return;
      
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final lastDate = DateTime.utc(lastStreakDate.year, lastStreakDate.month, lastStreakDate.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      // Only reset if truly broken (more than 1 day gap)
      if (lastDate != today && lastDate != yesterday) {
        transaction.update(docRef, {
          'streak': 0,
          'lastStreakDate': Timestamp.fromDate(today),
        });
      }
    });
  }

  @override
  Future<void> updateStreak(String coupleId, {required bool allTasksCompleted}) async {
    // Snapchat-style: Streak increases on ANY interaction, not just all tasks completed
    await incrementStreakOnInteraction(coupleId);
  }

  /// Snapchat-style streak: Increments when user has ANY daily interaction
  /// Streak continues if there was interaction yesterday, resets if missed a day
  @override
  Future<void> incrementStreakOnInteraction(String coupleId) async {
    final docRef = _coupleDoc(coupleId);
    final interactionDocRef = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('daily_interactions')
        .doc('today');
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentStreak = (data['streak'] as num?)?.toInt() ?? 0;
      final lastStreakDate = (data['lastStreakDate'] as Timestamp?)?.toDate();
      
      // Use UTC for all date comparisons
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      // Check if already updated today
      if (lastStreakDate != null) {
        final lastDate = DateTime.utc(lastStreakDate.year, lastStreakDate.month, lastStreakDate.day);
        
        if (lastDate == today) {
          // Already interacted today - don't increment again, but mark interaction
          transaction.update(interactionDocRef, {
            'hasInteraction': true,
            'lastInteractionAt': Timestamp.fromDate(DateTime.now().toUtc()),
          });
          return;
        }
        
        // Check if yesterday had interaction (streak continues) or not (reset)
        if (lastDate != yesterday) {
          // Gap > 1 day: Streak broken - reset to 1 (new streak starts today)
          transaction.update(docRef, {
            'streak': 1,
            'lastStreakDate': Timestamp.fromDate(today),
          });
          transaction.set(interactionDocRef, {
            'hasInteraction': true,
            'date': Timestamp.fromDate(today),
            'lastInteractionAt': Timestamp.fromDate(DateTime.now().toUtc()),
          });
          return;
        }
      }
      
      // Increment streak (yesterday had interaction or first time)
      transaction.update(docRef, {
        'streak': currentStreak + 1,
        'lastStreakDate': Timestamp.fromDate(today),
      });
      transaction.set(interactionDocRef, {
        'hasInteraction': true,
        'date': Timestamp.fromDate(today),
        'lastInteractionAt': Timestamp.fromDate(DateTime.now().toUtc()),
      });
    });
  }

  @override
  Future<int> incrementTotalTasksCompleted(String userId) async {
    final docRef = _firestore.collection('users').doc(userId);
    
    return await _firestore.runTransaction<int>((transaction) async {
      final doc = await transaction.get(docRef);
      final currentTotal = (doc.data()?['totalTasksCompleted'] as num?)?.toInt() ?? 0;
      final newTotal = currentTotal + 1;
      
      transaction.set(docRef, {
        'totalTasksCompleted': newTotal,
      }, SetOptions(merge: true));
      
      return newTotal;
    });
  }

  @override
  Stream<int> watchTotalTasksCompleted(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      return (doc.data()?['totalTasksCompleted'] as num?)?.toInt() ?? 0;
    });
  }
}
