// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_question_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyQuestionRemoteDataSourceHash() =>
    r'0abb5408d8246eaa539da148400bb07814f20800';

/// See also [dailyQuestionRemoteDataSource].
@ProviderFor(dailyQuestionRemoteDataSource)
final dailyQuestionRemoteDataSourceProvider =
    AutoDisposeProvider<DailyQuestionRemoteDataSource>.internal(
  dailyQuestionRemoteDataSource,
  name: r'dailyQuestionRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyQuestionRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyQuestionRemoteDataSourceRef
    = AutoDisposeProviderRef<DailyQuestionRemoteDataSource>;
String _$dailyQuestionRepositoryHash() =>
    r'f0cbbf9f98a9186bddb57bc775344c1477118559';

/// See also [dailyQuestionRepository].
@ProviderFor(dailyQuestionRepository)
final dailyQuestionRepositoryProvider =
    AutoDisposeProvider<DailyQuestionRepository>.internal(
  dailyQuestionRepository,
  name: r'dailyQuestionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyQuestionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyQuestionRepositoryRef
    = AutoDisposeProviderRef<DailyQuestionRepository>;
String _$todaysQuestionHash() => r'78babee15158c25b3037df50c2aa42933b4a2967';

/// Stream of today's question for the current couple
///
/// Copied from [todaysQuestion].
@ProviderFor(todaysQuestion)
final todaysQuestionProvider =
    AutoDisposeStreamProvider<DailyQuestion?>.internal(
  todaysQuestion,
  name: r'todaysQuestionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todaysQuestionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodaysQuestionRef = AutoDisposeStreamProviderRef<DailyQuestion?>;
String _$pastQuestionsHash() => r'bd43a7adde3a55d834cfe2174d266d7760b78ddd';

/// Fetch past questions for archive screen
///
/// Copied from [pastQuestions].
@ProviderFor(pastQuestions)
final pastQuestionsProvider =
    AutoDisposeFutureProvider<List<DailyQuestion>>.internal(
  pastQuestions,
  name: r'pastQuestionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pastQuestionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PastQuestionsRef = AutoDisposeFutureProviderRef<List<DailyQuestion>>;
String _$dailyQuestionControllerHash() =>
    r'cd3622a0188f3d49dfe0466a27892fba6ac20a3f';

/// Controller for Daily Question actions
///
/// Copied from [DailyQuestionController].
@ProviderFor(DailyQuestionController)
final dailyQuestionControllerProvider =
    AutoDisposeAsyncNotifierProvider<DailyQuestionController, void>.internal(
  DailyQuestionController.new,
  name: r'dailyQuestionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyQuestionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DailyQuestionController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
