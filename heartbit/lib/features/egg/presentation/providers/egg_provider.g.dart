// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'egg_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eggRemoteDataSourceHash() =>
    r'b0cfc864fa64991408f5a4f1710ca0284a023fe2';

/// See also [eggRemoteDataSource].
@ProviderFor(eggRemoteDataSource)
final eggRemoteDataSourceProvider =
    AutoDisposeProvider<EggRemoteDataSource>.internal(
  eggRemoteDataSource,
  name: r'eggRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eggRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EggRemoteDataSourceRef = AutoDisposeProviderRef<EggRemoteDataSource>;
String _$eggRepositoryHash() => r'ba41d4f0920ff83a5d0b57b49f8d70c8c4276403';

/// See also [eggRepository].
@ProviderFor(eggRepository)
final eggRepositoryProvider = AutoDisposeProvider<EggRepository>.internal(
  eggRepository,
  name: r'eggRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eggRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EggRepositoryRef = AutoDisposeProviderRef<EggRepository>;
String _$eggControllerHash() => r'64c6e0755e558e99af686736982925d0e468dd8f';

/// See also [EggController].
@ProviderFor(EggController)
final eggControllerProvider =
    AutoDisposeAsyncNotifierProvider<EggController, void>.internal(
  EggController.new,
  name: r'eggControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eggControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EggController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
