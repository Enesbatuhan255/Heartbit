// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activityRemoteDataSourceHash() =>
    r'ddce1198495276c8858e3452ea1e50550b98905f';

/// See also [activityRemoteDataSource].
@ProviderFor(activityRemoteDataSource)
final activityRemoteDataSourceProvider =
    AutoDisposeProvider<ActivityRemoteDataSource>.internal(
  activityRemoteDataSource,
  name: r'activityRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activityRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityRemoteDataSourceRef
    = AutoDisposeProviderRef<ActivityRemoteDataSource>;
String _$activityRepositoryHash() =>
    r'fc0852bb58dea11557d07016915799c558232ede';

/// See also [activityRepository].
@ProviderFor(activityRepository)
final activityRepositoryProvider =
    AutoDisposeProvider<ActivityRepository>.internal(
  activityRepository,
  name: r'activityRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activityRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityRepositoryRef = AutoDisposeProviderRef<ActivityRepository>;
String _$availableActivitiesHash() =>
    r'4a9e580e3d8a9a8e12793452cb6e3e0fcae6eb11';

/// All available activities (global seed data)
///
/// Copied from [availableActivities].
@ProviderFor(availableActivities)
final availableActivitiesProvider =
    AutoDisposeStreamProvider<List<Activity>>.internal(
  availableActivities,
  name: r'availableActivitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableActivitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableActivitiesRef = AutoDisposeStreamProviderRef<List<Activity>>;
String _$unswipedActivitiesHash() =>
    r'd55d7912879a359bb8ff8be43fb87a83f3fe9531';

/// Activities not yet swiped by current user
///
/// Copied from [unswipedActivities].
@ProviderFor(unswipedActivities)
final unswipedActivitiesProvider =
    AutoDisposeFutureProvider<List<Activity>>.internal(
  unswipedActivities,
  name: r'unswipedActivitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unswipedActivitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnswipedActivitiesRef = AutoDisposeFutureProviderRef<List<Activity>>;
String _$bucketListHash() => r'2125d341b8dd62374d56230e0b4eb87c5fc74392';

/// Couple's bucket list (matched activities)
///
/// Copied from [bucketList].
@ProviderFor(bucketList)
final bucketListProvider = AutoDisposeStreamProvider<List<BucketItem>>.internal(
  bucketList,
  name: r'bucketListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bucketListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BucketListRef = AutoDisposeStreamProviderRef<List<BucketItem>>;
String _$swipeControllerHash() => r'508344bc07787b08e7e87c0d6a2a0d8f186757de';

/// See also [SwipeController].
@ProviderFor(SwipeController)
final swipeControllerProvider =
    AutoDisposeAsyncNotifierProvider<SwipeController, void>.internal(
  SwipeController.new,
  name: r'swipeControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$swipeControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SwipeController = AutoDisposeAsyncNotifier<void>;
String _$matchEventHash() => r'045f2441361e3133ce8d3df11db2bddbf91f6af8';

/// Event provider for match celebration
///
/// Copied from [MatchEvent].
@ProviderFor(MatchEvent)
final matchEventProvider =
    AutoDisposeNotifierProvider<MatchEvent, String?>.internal(
  MatchEvent.new,
  name: r'matchEventProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$matchEventHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MatchEvent = AutoDisposeNotifier<String?>;
String _$bucketListControllerHash() =>
    r'68dcbbfcf79c9ed33b8d05632bde1821729d6b31';

/// See also [BucketListController].
@ProviderFor(BucketListController)
final bucketListControllerProvider =
    AutoDisposeAsyncNotifierProvider<BucketListController, void>.internal(
  BucketListController.new,
  name: r'bucketListControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bucketListControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BucketListController = AutoDisposeAsyncNotifier<void>;
String _$wheelControllerHash() => r'046c8246d6cb3df0e17ffd11f52a5e05ac67b1a3';

/// See also [WheelController].
@ProviderFor(WheelController)
final wheelControllerProvider =
    AutoDisposeAsyncNotifierProvider<WheelController, void>.internal(
  WheelController.new,
  name: r'wheelControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wheelControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WheelController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
