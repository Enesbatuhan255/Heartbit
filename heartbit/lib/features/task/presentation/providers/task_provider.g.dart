// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskRemoteDataSourceHash() =>
    r'ee5052701a6d123776d39a655642e44b8d6c95db';

/// See also [taskRemoteDataSource].
@ProviderFor(taskRemoteDataSource)
final taskRemoteDataSourceProvider =
    AutoDisposeProvider<TaskRemoteDataSource>.internal(
  taskRemoteDataSource,
  name: r'taskRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskRemoteDataSourceRef = AutoDisposeProviderRef<TaskRemoteDataSource>;
String _$taskRepositoryHash() => r'785927d1b070efa2795853c179fd8b25cc6ab292';

/// See also [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = AutoDisposeProvider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskRepositoryRef = AutoDisposeProviderRef<TaskRepository>;
String _$dailyTasksHash() => r'353cc163804abf16488c3dfb7c47d5c579dfd5e1';

/// See also [dailyTasks].
@ProviderFor(dailyTasks)
final dailyTasksProvider = AutoDisposeStreamProvider<List<DailyTask>>.internal(
  dailyTasks,
  name: r'dailyTasksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dailyTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyTasksRef = AutoDisposeStreamProviderRef<List<DailyTask>>;
String _$streakHash() => r'c9f9a5380e46f1458618dfa7e278116c9583ce15';

/// See also [streak].
@ProviderFor(streak)
final streakProvider = AutoDisposeStreamProvider<int>.internal(
  streak,
  name: r'streakProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$streakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StreakRef = AutoDisposeStreamProviderRef<int>;
String _$taskControllerHash() => r'35ad9a9e0cf1e657687c8ff92d1439bcda9b5e2f';

/// See also [TaskController].
@ProviderFor(TaskController)
final taskControllerProvider =
    AutoDisposeAsyncNotifierProvider<TaskController, void>.internal(
  TaskController.new,
  name: r'taskControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
