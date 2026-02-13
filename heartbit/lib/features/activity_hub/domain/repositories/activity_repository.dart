import '../entities/activity.dart';
import '../entities/bucket_item.dart';

abstract class ActivityRepository {
  /// Watch all available activities (global seed data)
  Stream<List<Activity>> watchActivities();

  /// Record a user's swipe on an activity
  Future<void> recordSwipe(String coupleId, String activityId, String odCiU4q9nSb, bool liked);

  /// Check if both users liked the same activity (match check)
  Future<bool> checkForMatch(String coupleId, String activityId);

  /// Add matched activity to bucket list
  Future<void> addToBucketList(String coupleId, String activityId);

  /// Watch couple's bucket list
  Stream<List<BucketItem>> watchBucketList(String coupleId);

  /// Update bucket item status (pending -> planned -> completed)
  Future<void> updateBucketItemStatus(String coupleId, String itemId, String status, {DateTime? plannedDate});

  /// Log wheel spin to history
  Future<void> logWheelSpin(String coupleId, String activityId, String source, String odCiU4q9nSb);

  /// Get activities already swiped by user (to filter out)
  Future<List<String>> getSwipedActivityIds(String coupleId, String odCiU4q9nSb);
}
