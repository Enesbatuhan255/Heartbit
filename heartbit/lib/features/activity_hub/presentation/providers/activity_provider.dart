import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';

import '../../domain/entities/activity.dart';
import '../../domain/entities/bucket_item.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../data/datasources/activity_remote_datasource.dart';
import '../../data/repositories/activity_repository_impl.dart';

part 'activity_provider.g.dart';

// --- Data Layer Providers ---

@riverpod
ActivityRemoteDataSource activityRemoteDataSource(ActivityRemoteDataSourceRef ref) {
  return ActivityRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
ActivityRepository activityRepository(ActivityRepositoryRef ref) {
  return ActivityRepositoryImpl(
    remoteDataSource: ref.watch(activityRemoteDataSourceProvider),
  );
}

// --- Activity Data Providers ---

/// All available activities (global seed data)
@riverpod
Stream<List<Activity>> availableActivities(AvailableActivitiesRef ref) {
  return ref.watch(activityRepositoryProvider).watchActivities();
}

/// Activities not yet swiped by current user
@riverpod
Future<List<Activity>> unswipedActivities(UnswipedActivitiesRef ref) async {
  final userId = ref.watch(authUserIdProvider);
  final coupleAsync = ref.watch(coupleStateProvider);
  
  if (userId == null || !coupleAsync.hasValue || coupleAsync.value == null) {
    return [];
  }
  
  final coupleId = coupleAsync.value!.id;
  final allActivities = await ref.watch(availableActivitiesProvider.future);
  final swipedIds = await ref.watch(activityRepositoryProvider)
      .getSwipedActivityIds(coupleId, userId);
  
  return allActivities.where((a) => !swipedIds.contains(a.id)).toList();
}

/// Couple's bucket list (matched activities)
@riverpod
Stream<List<BucketItem>> bucketList(BucketListRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  
  if (!coupleAsync.hasValue || coupleAsync.value == null) {
    return const Stream.empty();
  }
  
  return ref.watch(activityRepositoryProvider).watchBucketList(coupleAsync.value!.id);
}

// --- Swipe Controller ---

@riverpod
class SwipeController extends _$SwipeController {
  @override
  FutureOr<void> build() {}

  Future<bool> swipe(String activityId, bool liked) async {
    final coupleAsync = ref.read(coupleStateProvider);
    final userId = ref.read(authUserIdProvider);
    
    if (!coupleAsync.hasValue || coupleAsync.value == null || userId == null) {
      return false;
    }
    
    final coupleId = coupleAsync.value!.id;
    final repo = ref.read(activityRepositoryProvider);

    state = const AsyncLoading();
    
    try {
      // 1. Record MY swipe (partner can't see it yet)
      await repo.recordSwipe(coupleId, activityId, userId, liked);
      
      // 2. Check if BOTH liked (only if I liked)
      if (liked) {
        final isMatch = await repo.checkForMatch(coupleId, activityId);
        if (isMatch) {
          // 3. Add to Bucket List
          await repo.addToBucketList(coupleId, activityId);
          
          // 4. Trigger celebration (handled by matchEventProvider)
          ref.read(matchEventProvider.notifier).state = activityId;
          
          state = const AsyncData(null);
          return true; // Match!
        }
      }
      
      state = const AsyncData(null);
      return false; // No match
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

/// Event provider for match celebration
@riverpod
class MatchEvent extends _$MatchEvent {
  @override
  String? build() => null;
  
  void clear() => state = null;
}

// --- Bucket List Controller ---

@riverpod
class BucketListController extends _$BucketListController {
  @override
  FutureOr<void> build() {}

  Future<void> updateItemStatus(
    String itemId,
    String newStatus, {
    DateTime? plannedDate,
  }) async {
    final coupleAsync = ref.read(coupleStateProvider);
    
    if (!coupleAsync.hasValue || coupleAsync.value == null) {
      return;
    }
    
    final coupleId = coupleAsync.value!.id;
    final repo = ref.read(activityRepositoryProvider);

    state = const AsyncLoading();
    
    try {
      await repo.updateBucketItemStatus(
        coupleId,
        itemId,
        newStatus,
        plannedDate: plannedDate,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// --- Wheel Controller ---

@riverpod
class WheelController extends _$WheelController {
  @override
  FutureOr<void> build() {}

  Future<Activity?> spin(List<Activity> items, String source) async {
    if (items.isEmpty) return null;
    
    final coupleAsync = ref.read(coupleStateProvider);
    final userId = ref.read(authUserIdProvider);
    
    if (!coupleAsync.hasValue || coupleAsync.value == null || userId == null) {
      return null;
    }
    
    final random = Random();
    final selected = items[random.nextInt(items.length)];
    
    // Log to history
    await ref.read(activityRepositoryProvider).logWheelSpin(
      coupleAsync.value!.id,
      selected.id,
      source,
      userId,
    );
    
    return selected;
  }
}
