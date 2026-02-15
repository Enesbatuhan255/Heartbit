// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$globalActivityDataSourceHash() =>
    r'6d85d69054dbab0c2cdfec4280274bc6c88e7a26';

/// See also [globalActivityDataSource].
@ProviderFor(globalActivityDataSource)
final globalActivityDataSourceProvider =
    AutoDisposeProvider<GlobalActivityDataSource>.internal(
  globalActivityDataSource,
  name: r'globalActivityDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$globalActivityDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GlobalActivityDataSourceRef
    = AutoDisposeProviderRef<GlobalActivityDataSource>;
String _$customActivityDataSourceHash() =>
    r'315b756e1ca41b1962f41b6cfb48e60399ea5aa9';

/// See also [customActivityDataSource].
@ProviderFor(customActivityDataSource)
final customActivityDataSourceProvider =
    AutoDisposeProvider<CustomActivityDataSource>.internal(
  customActivityDataSource,
  name: r'customActivityDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customActivityDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomActivityDataSourceRef
    = AutoDisposeProviderRef<CustomActivityDataSource>;
String _$swipeSessionDataSourceHash() =>
    r'456ac5e284b6b65824e2c7c463594be466aa0cea';

/// See also [swipeSessionDataSource].
@ProviderFor(swipeSessionDataSource)
final swipeSessionDataSourceProvider =
    AutoDisposeProvider<SwipeSessionDataSource>.internal(
  swipeSessionDataSource,
  name: r'swipeSessionDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$swipeSessionDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SwipeSessionDataSourceRef
    = AutoDisposeProviderRef<SwipeSessionDataSource>;
String _$deckGeneratorServiceHash() =>
    r'32336499b4b9970a1009cec2ab049bd8b99c126e';

/// See also [deckGeneratorService].
@ProviderFor(deckGeneratorService)
final deckGeneratorServiceProvider =
    AutoDisposeProvider<DeckGeneratorService>.internal(
  deckGeneratorService,
  name: r'deckGeneratorServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deckGeneratorServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeckGeneratorServiceRef = AutoDisposeProviderRef<DeckGeneratorService>;
String _$customActivitiesHash() => r'0fc32310bdbd0662dcee3dd496e889b5dd9189f0';

/// See also [customActivities].
@ProviderFor(customActivities)
final customActivitiesProvider =
    AutoDisposeStreamProvider<List<CustomActivity>>.internal(
  customActivities,
  name: r'customActivitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customActivitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomActivitiesRef
    = AutoDisposeStreamProviderRef<List<CustomActivity>>;
String _$activityMatchesHash() => r'47e7ecf09c55ce1a3bbfa2e84451b810439260bd';

/// See also [activityMatches].
@ProviderFor(activityMatches)
final activityMatchesProvider =
    AutoDisposeStreamProvider<List<ActivityMatch>>.internal(
  activityMatches,
  name: r'activityMatchesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activityMatchesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityMatchesRef = AutoDisposeStreamProviderRef<List<ActivityMatch>>;
String _$selectedCategoriesHash() =>
    r'349d9b31189733b3cdf50db186960766dc7699f4';

/// Holds the currently selected categories for the session
///
/// Copied from [SelectedCategories].
@ProviderFor(SelectedCategories)
final selectedCategoriesProvider = AutoDisposeNotifierProvider<
    SelectedCategories, Set<ActivityCategory>>.internal(
  SelectedCategories.new,
  name: r'selectedCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedCategories = AutoDisposeNotifier<Set<ActivityCategory>>;
String _$selectedBudgetsHash() => r'd541b2da2141e553f049d2420e8cab88d19367e0';

/// Holds selected budget levels (1=$, 2=$$, 3=$$$)
///
/// Copied from [SelectedBudgets].
@ProviderFor(SelectedBudgets)
final selectedBudgetsProvider =
    AutoDisposeNotifierProvider<SelectedBudgets, Set<int>>.internal(
  SelectedBudgets.new,
  name: r'selectedBudgetsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedBudgetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedBudgets = AutoDisposeNotifier<Set<int>>;
String _$selectedDurationsHash() => r'fdda76e9a9de29f52d3d8b3a711f0dc0e5100a39';

/// Holds selected duration tiers ('quick', 'medium', 'long')
///
/// Copied from [SelectedDurations].
@ProviderFor(SelectedDurations)
final selectedDurationsProvider =
    AutoDisposeNotifierProvider<SelectedDurations, Set<String>>.internal(
  SelectedDurations.new,
  name: r'selectedDurationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedDurationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDurations = AutoDisposeNotifier<Set<String>>;
String _$sessionCustomActivitiesHash() =>
    r'bd517c8e0653f691ae8c08c2ac4754a4cf6a93a6';

/// Holds temporary custom activities added for this session
///
/// Copied from [SessionCustomActivities].
@ProviderFor(SessionCustomActivities)
final sessionCustomActivitiesProvider =
    AutoDisposeNotifierProvider<SessionCustomActivities, List<String>>.internal(
  SessionCustomActivities.new,
  name: r'sessionCustomActivitiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionCustomActivitiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionCustomActivities = AutoDisposeNotifier<List<String>>;
String _$swipeDeckControllerHash() =>
    r'd13a95205c2025f247c3196ed1f453ab521df0c4';

/// See also [SwipeDeckController].
@ProviderFor(SwipeDeckController)
final swipeDeckControllerProvider = AutoDisposeAsyncNotifierProvider<
    SwipeDeckController, List<Activity>>.internal(
  SwipeDeckController.new,
  name: r'swipeDeckControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$swipeDeckControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SwipeDeckController = AutoDisposeAsyncNotifier<List<Activity>>;
String _$swipeSessionControllerHash() =>
    r'cf25a54f5e8e367e65faa12eba600360eb218af0';

/// See also [SwipeSessionController].
@ProviderFor(SwipeSessionController)
final swipeSessionControllerProvider =
    AutoDisposeAsyncNotifierProvider<SwipeSessionController, void>.internal(
  SwipeSessionController.new,
  name: r'swipeSessionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$swipeSessionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SwipeSessionController = AutoDisposeAsyncNotifier<void>;
String _$matchEventNotifierHash() =>
    r'69400d6d879de9076358bb35bc7ee26a1f231c42';

/// See also [MatchEventNotifier].
@ProviderFor(MatchEventNotifier)
final matchEventNotifierProvider =
    AutoDisposeNotifierProvider<MatchEventNotifier, Activity?>.internal(
  MatchEventNotifier.new,
  name: r'matchEventNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$matchEventNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MatchEventNotifier = AutoDisposeNotifier<Activity?>;
String _$customActivityControllerHash() =>
    r'f1838f444450b30e7ed1b47cbf42f77361dafef4';

/// See also [CustomActivityController].
@ProviderFor(CustomActivityController)
final customActivityControllerProvider =
    AutoDisposeAsyncNotifierProvider<CustomActivityController, void>.internal(
  CustomActivityController.new,
  name: r'customActivityControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customActivityControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CustomActivityController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
