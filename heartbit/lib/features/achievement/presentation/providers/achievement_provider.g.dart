// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$achievementDataSourceHash() =>
    r'60520e6d9734ecc78cd867683de7fd382dafeb2a';

/// See also [achievementDataSource].
@ProviderFor(achievementDataSource)
final achievementDataSourceProvider =
    AutoDisposeProvider<AchievementDataSource>.internal(
  achievementDataSource,
  name: r'achievementDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$achievementDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AchievementDataSourceRef
    = AutoDisposeProviderRef<AchievementDataSource>;
String _$unlockedAchievementsHash() =>
    r'b8e04fd5ba1050d4576a4d088ffcd06d701d43a2';

/// Stream of unlocked achievements for the current couple
///
/// Copied from [unlockedAchievements].
@ProviderFor(unlockedAchievements)
final unlockedAchievementsProvider =
    AutoDisposeStreamProvider<List<UnlockedAchievement>>.internal(
  unlockedAchievements,
  name: r'unlockedAchievementsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unlockedAchievementsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnlockedAchievementsRef
    = AutoDisposeStreamProviderRef<List<UnlockedAchievement>>;
String _$achievementListHash() => r'77c002548664e7467e371fefe055cb96be547214';

/// Combined view: All achievements with unlock status
///
/// Copied from [AchievementList].
@ProviderFor(AchievementList)
final achievementListProvider = AutoDisposeNotifierProvider<AchievementList,
    List<AchievementWithStatus>>.internal(
  AchievementList.new,
  name: r'achievementListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$achievementListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AchievementList = AutoDisposeNotifier<List<AchievementWithStatus>>;
String _$achievementControllerHash() =>
    r'297b222a2165fed279245cd7a0c79190b55a6532';

/// Controller for achievement actions
///
/// Copied from [AchievementController].
@ProviderFor(AchievementController)
final achievementControllerProvider =
    AutoDisposeAsyncNotifierProvider<AchievementController, void>.internal(
  AchievementController.new,
  name: r'achievementControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$achievementControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AchievementController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
