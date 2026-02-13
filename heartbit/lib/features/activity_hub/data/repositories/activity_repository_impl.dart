import '../../domain/entities/activity.dart';
import '../../domain/entities/bucket_item.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_remote_datasource.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityRemoteDataSource _remoteDataSource;

  ActivityRepositoryImpl({required ActivityRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Stream<List<Activity>> watchActivities() {
    return _remoteDataSource.watchActivities();
  }

  @override
  Future<void> recordSwipe(String coupleId, String activityId, String userId, bool liked) {
    return _remoteDataSource.recordSwipe(coupleId, activityId, userId, liked);
  }

  @override
  Future<bool> checkForMatch(String coupleId, String activityId) {
    return _remoteDataSource.checkForMatch(coupleId, activityId);
  }

  @override
  Future<void> addToBucketList(String coupleId, String activityId) {
    return _remoteDataSource.addToBucketList(coupleId, activityId);
  }

  @override
  Stream<List<BucketItem>> watchBucketList(String coupleId) {
    return _remoteDataSource.watchBucketList(coupleId);
  }

  @override
  Future<void> updateBucketItemStatus(
    String coupleId, 
    String itemId, 
    String status, 
    {DateTime? plannedDate}
  ) {
    return _remoteDataSource.updateBucketItemStatus(
      coupleId, 
      itemId, 
      status, 
      plannedDate: plannedDate,
    );
  }

  @override
  Future<void> logWheelSpin(String coupleId, String activityId, String source, String userId) {
    return _remoteDataSource.logWheelSpin(coupleId, activityId, source, userId);
  }

  @override
  Future<List<String>> getSwipedActivityIds(String coupleId, String userId) {
    return _remoteDataSource.getSwipedActivityIds(coupleId, userId);
  }
}
