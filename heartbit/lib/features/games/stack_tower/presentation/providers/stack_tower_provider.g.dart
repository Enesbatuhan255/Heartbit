// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stack_tower_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stackTowerDataSourceHash() =>
    r'454850e495e23231ffe397923b2278368f0a3e19';

/// See also [stackTowerDataSource].
@ProviderFor(stackTowerDataSource)
final stackTowerDataSourceProvider =
    AutoDisposeProvider<StackTowerRemoteDataSource>.internal(
  stackTowerDataSource,
  name: r'stackTowerDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stackTowerDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StackTowerDataSourceRef
    = AutoDisposeProviderRef<StackTowerRemoteDataSource>;
String _$activeStackTowerSessionHash() =>
    r'e1c779846f91c648703b204ec70173e208c9dfad';

/// Active stack tower session for the current couple
///
/// Copied from [activeStackTowerSession].
@ProviderFor(activeStackTowerSession)
final activeStackTowerSessionProvider =
    AutoDisposeStreamProvider<StackTowerSession?>.internal(
  activeStackTowerSession,
  name: r'activeStackTowerSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeStackTowerSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveStackTowerSessionRef
    = AutoDisposeStreamProviderRef<StackTowerSession?>;
String _$stackTowerControllerHash() =>
    r'778eb43d01664fa9152d8b94fba5f74d59c00dfc';

/// See also [StackTowerController].
@ProviderFor(StackTowerController)
final stackTowerControllerProvider =
    AutoDisposeAsyncNotifierProvider<StackTowerController, void>.internal(
  StackTowerController.new,
  name: r'stackTowerControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stackTowerControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StackTowerController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
