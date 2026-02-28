// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$moodRemoteDataSourceHash() =>
    r'2cf4cbadc1288f92955307d7507514c664179274';

/// See also [moodRemoteDataSource].
@ProviderFor(moodRemoteDataSource)
final moodRemoteDataSourceProvider =
    AutoDisposeProvider<MoodRemoteDataSource>.internal(
  moodRemoteDataSource,
  name: r'moodRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$moodRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MoodRemoteDataSourceRef = AutoDisposeProviderRef<MoodRemoteDataSource>;
String _$currentMoodHash() => r'11cef8ef2c31e8cac2bc901577a6e7111f368d8c';

/// Stream of today's mood from Firestore (persisted across app restarts)
///
/// Copied from [currentMood].
@ProviderFor(currentMood)
final currentMoodProvider = AutoDisposeStreamProvider<Mood?>.internal(
  currentMood,
  name: r'currentMoodProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentMoodHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMoodRef = AutoDisposeStreamProviderRef<Mood?>;
String _$partnerMoodHash() => r'0928567245769d8eaccf7f373cf6634da6cf1984';

/// Stream of partner's mood
///
/// Copied from [partnerMood].
@ProviderFor(partnerMood)
final partnerMoodProvider = AutoDisposeStreamProvider<Mood?>.internal(
  partnerMood,
  name: r'partnerMoodProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$partnerMoodHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PartnerMoodRef = AutoDisposeStreamProviderRef<Mood?>;
String _$moodControllerHash() => r'c70ba3108a898eeac1724b3d92c337988f1b3749';

/// Controller for mood actions
///
/// Copied from [MoodController].
@ProviderFor(MoodController)
final moodControllerProvider =
    AutoDisposeAsyncNotifierProvider<MoodController, void>.internal(
  MoodController.new,
  name: r'moodControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$moodControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MoodController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
