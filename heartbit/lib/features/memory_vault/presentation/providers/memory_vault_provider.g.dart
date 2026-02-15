// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_vault_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memoryRemoteDataSourceHash() =>
    r'ea2ca944fc750116926f3375fb51aacb303243a0';

/// See also [memoryRemoteDataSource].
@ProviderFor(memoryRemoteDataSource)
final memoryRemoteDataSourceProvider =
    AutoDisposeProvider<MemoryRemoteDataSource>.internal(
  memoryRemoteDataSource,
  name: r'memoryRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$memoryRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoryRemoteDataSourceRef
    = AutoDisposeProviderRef<MemoryRemoteDataSource>;
String _$memoryRepositoryHash() => r'969e6fffebeadcea58cdd5a8a0326f31f7cfa3f3';

/// See also [memoryRepository].
@ProviderFor(memoryRepository)
final memoryRepositoryProvider = AutoDisposeProvider<MemoryRepository>.internal(
  memoryRepository,
  name: r'memoryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$memoryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoryRepositoryRef = AutoDisposeProviderRef<MemoryRepository>;
String _$memoriesHash() => r'd332fcfb360ded9930c1e285cc3ba74901686349';

/// All memories for the current couple
///
/// Copied from [memories].
@ProviderFor(memories)
final memoriesProvider = AutoDisposeStreamProvider<List<Memory>>.internal(
  memories,
  name: r'memoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$memoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoriesRef = AutoDisposeStreamProviderRef<List<Memory>>;
String _$memoryControllerHash() => r'542c2ec3d88baadcb3da125e47e5d426b2f35184';

/// See also [MemoryController].
@ProviderFor(MemoryController)
final memoryControllerProvider =
    AutoDisposeAsyncNotifierProvider<MemoryController, void>.internal(
  MemoryController.new,
  name: r'memoryControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$memoryControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MemoryController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
